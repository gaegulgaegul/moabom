#!/usr/bin/env ruby
# frozen_string_literal: true

# JSONL 세션 로그를 MD 문서로 변환
# 사용법: ruby scripts/session_to_md.rb [jsonl_file]

require "json"
require "time"
require "fileutils"

class SessionToMarkdown
  def initialize(jsonl_path)
    @jsonl_path = jsonl_path
    @messages = []
    @session_info = {}
  end

  def convert
    parse_jsonl
    return if @messages.empty?

    generate_markdown
  end

  private

  def parse_jsonl
    File.readlines(@jsonl_path).each do |line|
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

    thinking_content = content_parts
      .select { |c| c["type"] == "thinking" }
      .map { |c| c["thinking"] }
      .join("\n")

    return if text_content.empty? && thinking_content.empty?

    @messages << {
      type: :assistant,
      content: text_content,
      thinking: thinking_content,
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
    output_path = @jsonl_path.sub(/\.jsonl$/, ".md")

    File.open(output_path, "w") do |f|
      write_header(f)
      write_messages(f)
      write_footer(f)
    end

    puts "Generated: #{output_path}"
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
    f.puts "| 프로젝트 | #{@session_info[:cwd]&.split("/")&.last || "Unknown"} |"
    f.puts "| 브랜치 | #{@session_info[:branch] || "Unknown"} |"
    f.puts "| Claude Code | #{@session_info[:version] || "Unknown"} |"
    f.puts
    f.puts "---"
    f.puts
  end

  def write_messages(f)
    @messages.each_with_index do |msg, idx|
      case msg[:type]
      when :user
        f.puts "## #{idx / 2 + 1}. 프롬프트"
        f.puts
        f.puts msg[:content]
        f.puts
      when :assistant
        f.puts "### 응답"
        f.puts
        if msg[:thinking] && !msg[:thinking].empty?
          f.puts "<details>"
          f.puts "<summary>사고 과정 (Thinking)</summary>"
          f.puts
          f.puts "```"
          # 사고 과정은 너무 길 수 있으니 요약
          thinking = msg[:thinking]
          if thinking.length > 1000
            thinking = thinking[0..1000] + "\n... (truncated)"
          end
          f.puts thinking
          f.puts "```"
          f.puts
          f.puts "</details>"
          f.puts
        end
        f.puts msg[:content]
        f.puts
        f.puts "---"
        f.puts
      end
    end
  end

  def write_footer(f)
    f.puts
    f.puts "*이 문서는 Claude Code 세션에서 자동 생성되었습니다.*"
  end
end

# 메인 실행
if __FILE__ == $PROGRAM_NAME
  if ARGV.empty?
    # 기본: docs/logs에서 가장 최근 jsonl 파일 찾기
    logs_dir = File.join(Dir.pwd, "docs", "logs")
    if Dir.exist?(logs_dir)
      jsonl_files = Dir.glob(File.join(logs_dir, "*.jsonl")).sort_by { |f| File.mtime(f) }
      if jsonl_files.any?
        SessionToMarkdown.new(jsonl_files.last).convert
      else
        puts "No JSONL files found in #{logs_dir}"
      end
    else
      puts "Logs directory not found: #{logs_dir}"
    end
  else
    ARGV.each do |path|
      if File.exist?(path)
        SessionToMarkdown.new(path).convert
      else
        puts "File not found: #{path}"
      end
    end
  end
end
