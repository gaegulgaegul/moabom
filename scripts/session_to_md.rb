#!/usr/bin/env ruby
# frozen_string_literal: true

# Claude Code 세션 JSONL을 MD 문서로 변환
# SessionEnd hook에서 자동 실행됨
#
# 환경변수:
#   CLAUDE_SESSION_ID - 현재 세션 ID
#   CLAUDE_PROJECT_DIR - 프로젝트 디렉토리

require "json"
require "time"
require "fileutils"

class SessionToMarkdown
  CLAUDE_LOGS_BASE = File.expand_path("~/.claude/projects")

  def initialize(project_dir:, session_id: nil)
    @project_dir = project_dir
    @session_id = session_id
    @messages = []
    @session_info = {}
    @tool_uses = []
  end

  def convert
    jsonl_path = find_jsonl_file
    return unless jsonl_path && File.exist?(jsonl_path)

    parse_jsonl(jsonl_path)
    return if @messages.empty?

    generate_markdown
  end

  private

  def find_jsonl_file
    # 프로젝트 경로를 Claude Code 형식으로 인코딩
    encoded_path = @project_dir.gsub("/", "-")
    logs_dir = File.join(CLAUDE_LOGS_BASE, encoded_path)

    return nil unless Dir.exist?(logs_dir)

    # 세션 ID가 있으면 해당 파일 찾기
    if @session_id
      session_file = File.join(logs_dir, "#{@session_id}.jsonl")
      return session_file if File.exist?(session_file)
    end

    # 없으면 가장 최근 수정된 메인 세션 파일 (agent- 제외)
    jsonl_files = Dir.glob(File.join(logs_dir, "*.jsonl"))
      .reject { |f| File.basename(f).start_with?("agent-") }
      .sort_by { |f| File.mtime(f) }

    jsonl_files.last
  end

  def parse_jsonl(path)
    @jsonl_path = path

    File.readlines(path).each do |line|
      next if line.strip.empty?

      begin
        data = JSON.parse(line)
        process_entry(data)
      rescue JSON::ParserError
        next
      end
    end
  end

  def process_entry(data)
    case data["type"]
    when "user"
      add_user_message(data)
    when "assistant"
      add_assistant_message(data)
    end

    # 세션 정보 추출
    @session_info[:session_id] ||= data["sessionId"]
    @session_info[:cwd] ||= data["cwd"]
    @session_info[:branch] ||= data["gitBranch"]
    @session_info[:version] ||= data["version"]
  end

  def add_user_message(data)
    content = extract_content(data.dig("message", "content"))
    return if content.nil? || content.empty?
    return if content.include?("[Request interrupted")

    @messages << {
      type: :user,
      content: content,
      timestamp: data["timestamp"]
    }
  end

  def add_assistant_message(data)
    message = data["message"]
    return unless message

    content_parts = message["content"]
    return unless content_parts.is_a?(Array)

    text_content = content_parts
      .select { |c| c["type"] == "text" }
      .map { |c| c["text"] }
      .join("\n")

    tool_uses = content_parts
      .select { |c| c["type"] == "tool_use" }
      .map { |c| { name: c["name"], input: c["input"] } }

    return if text_content.empty? && tool_uses.empty?

    @messages << {
      type: :assistant,
      content: text_content,
      tool_uses: tool_uses,
      timestamp: data["timestamp"],
      model: message["model"]
    }
  end

  def extract_content(content)
    case content
    when String
      content
    when Array
      content.select { |c| c["type"] == "text" }.map { |c| c["text"] }.join("\n")
    end
  end

  def generate_markdown
    # docs/logs 디렉토리 생성
    output_dir = File.join(@project_dir, "docs", "logs")
    FileUtils.mkdir_p(output_dir)

    # 타임스탬프 기반 파일명
    timestamp = @messages.first&.dig(:timestamp)
    date_str = timestamp ? Time.parse(timestamp).strftime("%Y%m%d_%H%M%S") : Time.now.strftime("%Y%m%d_%H%M%S")
    output_path = File.join(output_dir, "#{date_str}.md")

    # 이미 존재하면 스킵
    return if File.exist?(output_path)

    File.open(output_path, "w") do |f|
      write_header(f)
      write_summary(f)
      write_messages(f)
      write_footer(f)
    end

    puts "✅ 세션 로그 생성: #{output_path}"
    output_path
  end

  def write_header(f)
    timestamp = @messages.first&.dig(:timestamp)
    date = timestamp ? Time.parse(timestamp).strftime("%Y-%m-%d %H:%M") : "Unknown"

    f.puts "# Claude Code 세션 로그"
    f.puts
    f.puts "| 항목 | 값 |"
    f.puts "|------|-----|"
    f.puts "| 날짜 | #{date} |"
    f.puts "| 프로젝트 | #{@session_info[:cwd]&.split('/')&.last || File.basename(@project_dir)} |"
    f.puts "| 브랜치 | #{@session_info[:branch] || 'Unknown'} |"
    f.puts "| Claude Code | #{@session_info[:version] || 'Unknown'} |"
    f.puts
    f.puts "---"
    f.puts
  end

  def write_summary(f)
    user_count = @messages.count { |m| m[:type] == :user }
    assistant_count = @messages.count { |m| m[:type] == :assistant }
    tool_count = @messages.sum { |m| m[:tool_uses]&.size || 0 }

    f.puts "## 요약"
    f.puts
    f.puts "- 대화 턴: #{user_count}"
    f.puts "- 도구 사용: #{tool_count}회"
    f.puts
    f.puts "---"
    f.puts
  end

  def write_messages(f)
    turn = 0
    @messages.each do |msg|
      case msg[:type]
      when :user
        turn += 1
        f.puts "## #{turn}. 사용자"
        f.puts
        content = msg[:content]
        # 너무 긴 내용은 truncate
        if content.length > 2000
          content = content[0..2000] + "\n\n... (truncated)"
        end
        f.puts content
        f.puts
      when :assistant
        f.puts "### Claude 응답"
        f.puts

        # 도구 사용 요약
        if msg[:tool_uses]&.any?
          f.puts "<details>"
          f.puts "<summary>🔧 도구 사용 (#{msg[:tool_uses].size}개)</summary>"
          f.puts
          msg[:tool_uses].each do |tool|
            f.puts "- **#{tool[:name]}**"
            if tool[:input].is_a?(Hash) && tool[:input]["file_path"]
              f.puts "  - `#{tool[:input]['file_path']}`"
            end
          end
          f.puts
          f.puts "</details>"
          f.puts
        end

        content = msg[:content]
        if content && !content.empty?
          # 너무 긴 내용은 truncate
          if content.length > 3000
            content = content[0..3000] + "\n\n... (truncated)"
          end
          f.puts content
        end
        f.puts
        f.puts "---"
        f.puts
      end
    end
  end

  def write_footer(f)
    f.puts
    f.puts "*이 문서는 Claude Code SessionEnd hook에서 자동 생성되었습니다.*"
  end
end

# 메인 실행
if __FILE__ == $PROGRAM_NAME
  project_dir = ENV["CLAUDE_PROJECT_DIR"] || Dir.pwd
  session_id = ENV["CLAUDE_SESSION_ID"]

  converter = SessionToMarkdown.new(
    project_dir: project_dir,
    session_id: session_id
  )

  converter.convert
end
