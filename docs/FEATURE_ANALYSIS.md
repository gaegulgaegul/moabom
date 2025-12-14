# 추가 기능 분석

> 작성일: 2025-12-14

---

## 0. 주요 서비스 얼굴 인식 기술 분석

### 0.1 공통 프로세스 (업계 표준)

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    얼굴 인식 파이프라인 (공통)                            │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  1. Face Detection (얼굴 감지)                                           │
│     └─ 사진에서 얼굴 영역 찾기 (bounding box)                             │
│                                                                          │
│  2. Face Alignment (얼굴 정렬)                                           │
│     └─ 눈, 코, 입 위치 맞춰서 정규화                                      │
│                                                                          │
│  3. Feature Extraction (특징 추출)                                       │
│     └─ 얼굴을 128~512차원 벡터(Embedding)로 변환                         │
│                                                                          │
│  4. Similarity Matching (유사도 비교)                                    │
│     └─ Cosine Similarity 또는 Euclidean Distance로 비교                 │
│                                                                          │
│  5. Clustering (그룹핑)                                                  │
│     └─ 비슷한 얼굴끼리 자동 그룹화 (DBSCAN, Agglomerative 등)            │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### 0.2 Google Photos 방식

| 항목 | 내용 |
|-----|------|
| **처리 위치** | 서버 + 일부 온디바이스 |
| **핵심 기술** | FaceNet 기반 딥러닝 |
| **특징** | 얼굴 + 옷 + 시간대 조합 분석 |

**프로세스:**
```
1. 얼굴 감지 → 얼굴 영역 추출
2. 얼굴 정렬 → 눈, 코, 입 위치 표준화
3. 수치화 → 얼굴을 숫자 벡터로 변환 (Face Embedding)
4. 유사도 비교 → 비슷한 얼굴끼리 그룹핑
5. 추가 분석 → 옷, 촬영 시간으로 보완 (얼굴 안 보여도 태깅 가능)
```

**특이점:**
- 뒷모습도 인식 가능 (옷 + 시간대 분석)
- 마스크 쓴 얼굴도 인식 (2021-2022 개선)
- Google 연락처, 이메일 데이터와 연동하여 이름 추천

**참고:** [How Does Google Photos Recognize Faces](https://luxand.cloud/face-recognition-blog/how-does-google-photos-recognize-the-names-and-faces)

---

### 0.3 Apple Photos 방식

| 항목 | 내용 |
|-----|------|
| **처리 위치** | 100% 온디바이스 (프라이버시 최우선) |
| **핵심 기술** | Vision Framework + Core ML |
| **특징** | 얼굴 + 상체 동시 분석 |

**프로세스:**
```
1. 얼굴 + 상체 감지 → 둘 다 독립적으로 탐지
2. 각각 Embedding 생성 → 얼굴 벡터 + 상체 벡터
3. Agglomerative Clustering → 유사한 것끼리 그룹핑
4. 주기적 업데이트 → 충전 중 밤에 백그라운드 처리
```

**특이점:**
- 서버로 사진 전송 안 함 (완전 프라이버시)
- 얼굴 가려져도 상체로 인식 가능
- 얼굴 Embedding 생성: **4ms** (매우 빠름)
- iOS 15부터 극적으로 개선됨

**아키텍처:**
```
┌─────────────────────────────────────────┐
│              On-Device Processing        │
├─────────────────────────────────────────┤
│  ┌─────────────┐    ┌─────────────┐     │
│  │ Face Detect │    │ Body Detect │     │
│  └──────┬──────┘    └──────┬──────┘     │
│         │                  │            │
│         ▼                  ▼            │
│  ┌─────────────┐    ┌─────────────┐     │
│  │Face Embedding│   │Body Embedding│    │
│  │  (128-d)    │    │  (128-d)    │     │
│  └──────┬──────┘    └──────┬──────┘     │
│         │                  │            │
│         └────────┬─────────┘            │
│                  ▼                      │
│         ┌─────────────┐                 │
│         │ Clustering  │                 │
│         │(Agglomerative)│               │
│         └─────────────┘                 │
└─────────────────────────────────────────┘
```

**참고:** [Apple ML Research - People Recognition](https://machinelearning.apple.com/research/recognizing-people-photos)

---

### 0.4 Amazon Rekognition 방식

| 항목 | 내용 |
|-----|------|
| **처리 위치** | 100% 서버 (AWS 클라우드) |
| **핵심 기술** | Amazon 자체 딥러닝 |
| **특징** | Collection 기반 검색 |

**프로세스:**
```
1. 얼굴 감지 → 사진당 최대 100개 얼굴 탐지
2. 특징 추출 → Face Vector 생성
3. Collection 저장 → 서버에 벡터 저장 (이미지 X, 벡터만)
4. 검색 → 새 얼굴과 Collection 비교
5. 매칭 → 유사도 점수 반환
```

**특이점:**
- 얼굴 이미지 저장 안 함 (벡터만 저장)
- 실시간 검색 가능
- 감정, 나이, 성별 추가 분석 가능

**API 흐름:**
```
IndexFaces (저장)
  └─ 사진 → 얼굴 탐지 → 벡터 추출 → Collection 저장

SearchFaces (검색)
  └─ 새 얼굴 벡터 → Collection 비교 → 매칭 결과 반환
```

**참고:** [AWS Rekognition](https://aws.amazon.com/rekognition/)

---

### 0.5 오픈소스 옵션 비교

| 라이브러리 | 정확도 (LFW) | 속도 | 언어 | 특징 |
|-----------|-------------|------|------|------|
| **InsightFace** | 99.86% | 중간 | Python | 최고 정확도, ArcFace 모델 |
| **DeepFace** | 99.40% | 중간 | Python | 여러 모델 지원 (wrapper) |
| **dlib** | 99.38% | 빠름 | C++/Python | 가볍고 빠름 |
| **face-api.js** | ~95% | 느림 | JavaScript | 브라우저에서 실행 가능 |
| **OpenCV** | ~90% | 매우 빠름 | C++/Python | 기본적인 감지만 |

**LFW = Labeled Faces in the Wild (표준 벤치마크)**
**참고:** 사람 평균 정확도는 97.53%

---

### 0.6 핵심 기술: Face Embedding

**Embedding이란?**
```
얼굴 이미지 → 128차원 숫자 벡터로 변환

예시:
김철수 얼굴 → [0.12, -0.34, 0.56, ..., 0.78]  (128개 숫자)
김철수 다른 사진 → [0.11, -0.33, 0.55, ..., 0.77]  (비슷한 벡터)
다른 사람 → [0.89, 0.45, -0.23, ..., -0.56]  (다른 벡터)
```

**유사도 계산:**
```python
# Cosine Similarity (가장 많이 사용)
similarity = dot(vector1, vector2) / (norm(vector1) * norm(vector2))

# 같은 사람: similarity > 0.6 (보통 임계값)
# 다른 사람: similarity < 0.6
```

**FaceNet 논문:** [FaceNet: A Unified Embedding for Face Recognition and Clustering](https://arxiv.org/abs/1503.03832)

---

### 0.7 모아봄에 적용 가능한 전략

| Phase | 방식 | 장점 | 단점 |
|-------|------|------|------|
| **MVP** | 수동 태깅 | 즉시 구현, 100% 정확 | 귀찮음 |
| **v1.1** | face-api.js (클라이언트) | 무료, 프라이버시 | 정확도 중간 |
| **v1.2** | InsightFace (서버) | 최고 정확도 | Python 서버 필요 |
| **v2.0** | AWS Rekognition | 쉬운 구현, 고정확도 | 비용 발생 |

**권장: Apple 방식 참고**
```
1. 클라이언트에서 얼굴 감지 + Embedding 생성
2. Embedding만 서버로 전송 (이미지 X)
3. 서버에서 Clustering
4. 프라이버시 보호 + 비용 절감
```

---

## 1. 얼굴 인식 자동 태깅

### 1.1 기능 요약

```
사진 업로드 → 얼굴 감지 → 기존 프로필과 매칭 → 자동 태깅 → 태그별 필터링
```

**사용자 시나리오:**
1. 아이/가족 프로필에 얼굴 사진 등록 (기준 얼굴)
2. 새 사진 업로드 시 자동으로 "이 사진에 누가 있는지" 분석
3. "첫째 사진만 보기", "할머니랑 찍은 사진만" 필터링 가능

### 1.2 기술 옵션 비교

| 옵션 | 비용 | 정확도 | 처리 위치 | 난이도 |
|-----|------|--------|----------|--------|
| **AWS Rekognition** | $1/1000장 | 높음 | 서버 (API) | 쉬움 |
| **Google Vision** | $1.5/1000장 | 높음 | 서버 (API) | 쉬움 |
| **face-api.js** | 무료 | 중간 | 클라이언트 | 중간 |
| **InsightFace** | 무료 | 높음 | 서버 (Python) | 어려움 |
| **imgproxy + dlib** | 무료 | 중간 | 서버 | 어려움 |

### 1.3 권장: 단계별 접근

#### Phase 1 (MVP): 수동 태깅
```
- 가족 ~10명이니까 수동으로 충분
- 사진 업로드 시 "누구 사진인가요?" 선택
- 복잡한 인프라 불필요
- 비용: $0
```

#### Phase 2 (가족 확장): face-api.js
```
- 클라이언트 사이드 얼굴 인식 (브라우저/앱에서 처리)
- 서버 비용 없음
- TensorFlow.js 기반
- 정확도 ~85%
- 비용: $0
```

#### Phase 3 (퍼블릭): AWS Rekognition
```
- 서버 사이드 처리
- 정확도 ~98%
- 얼굴 컬렉션 기능 (자동 그룹핑)
- 비용: 월 $5~50 (사용량 기반)
```

### 1.4 데이터베이스 설계

```sql
-- 얼굴 프로필 (기준 얼굴)
CREATE TABLE face_profiles (
  id              BIGSERIAL PRIMARY KEY,
  family_id       BIGINT NOT NULL REFERENCES families(id),
  person_type     VARCHAR(20) NOT NULL,  -- 'child', 'adult'
  person_id       BIGINT,                 -- children.id 또는 users.id
  face_embedding  VECTOR(128),            -- 얼굴 벡터 (pgvector)
  source_photo_id BIGINT REFERENCES photos(id),
  confidence      DECIMAL(3,2),
  created_at      TIMESTAMP NOT NULL
);

-- 사진별 얼굴 태그
CREATE TABLE photo_faces (
  id              BIGSERIAL PRIMARY KEY,
  photo_id        BIGINT NOT NULL REFERENCES photos(id),
  face_profile_id BIGINT REFERENCES face_profiles(id),
  bounding_box    JSONB,                  -- {x, y, width, height}
  confidence      DECIMAL(3,2),
  manual_tagged   BOOLEAN DEFAULT FALSE,  -- 수동 태깅 여부
  created_at      TIMESTAMP NOT NULL
);

CREATE INDEX idx_photo_faces_photo ON photo_faces(photo_id);
CREATE INDEX idx_photo_faces_profile ON photo_faces(face_profile_id);
```

### 1.5 구현 흐름 (Phase 2 - face-api.js)

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Browser   │     │   Rails     │     │  Database   │
│  /Native    │     │   Server    │     │             │
└──────┬──────┘     └──────┬──────┘     └──────┬──────┘
       │                   │                   │
       │ 1. 사진 선택      │                   │
       │                   │                   │
       │ 2. face-api.js로  │                   │
       │    얼굴 감지      │                   │
       │    (클라이언트)   │                   │
       │                   │                   │
       │ 3. 얼굴 벡터 추출 │                   │
       │                   │                   │
       │ 4. 기존 프로필    │                   │
       │    벡터와 비교    │                   │
       │    (클라이언트)   │                   │
       │                   │                   │
       │ 5. 매칭 결과 +    │                   │
       │    사진 업로드    │                   │
       │──────────────────►│                   │
       │                   │                   │
       │                   │ 6. 저장           │
       │                   │──────────────────►│
       │                   │                   │
```

### 1.6 face-api.js 예시 코드

```javascript
// app/javascript/controllers/face_detection_controller.js
import { Controller } from "@hotwired/stimulus"
import * as faceapi from 'face-api.js'

export default class extends Controller {
  static targets = ["preview", "result"]
  static values = {
    profiles: Array  // 가족 얼굴 프로필 벡터들
  }

  async connect() {
    // 모델 로드 (최초 1회)
    await faceapi.nets.ssdMobilenetv1.loadFromUri('/models')
    await faceapi.nets.faceLandmark68Net.loadFromUri('/models')
    await faceapi.nets.faceRecognitionNet.loadFromUri('/models')
  }

  async detectFaces(event) {
    const file = event.target.files[0]
    const img = await faceapi.bufferToImage(file)

    // 얼굴 감지 + 벡터 추출
    const detections = await faceapi
      .detectAllFaces(img)
      .withFaceLandmarks()
      .withFaceDescriptors()

    // 기존 프로필과 매칭
    const matches = this.matchWithProfiles(detections)

    // 결과 표시
    this.showMatches(matches)
  }

  matchWithProfiles(detections) {
    const labeledDescriptors = this.profilesValue.map(p =>
      new faceapi.LabeledFaceDescriptors(p.name, [p.embedding])
    )

    const faceMatcher = new faceapi.FaceMatcher(labeledDescriptors, 0.6)

    return detections.map(d => ({
      detection: d,
      match: faceMatcher.findBestMatch(d.descriptor)
    }))
  }
}
```

### 1.7 고려사항

| 항목 | 내용 |
|-----|------|
| **아기 얼굴 변화** | 성장하면서 얼굴 변함 → 주기적으로 프로필 업데이트 권장 |
| **프라이버시** | 얼굴 벡터는 민감 정보 → 암호화 저장, 외부 전송 최소화 |
| **정확도** | 비슷한 나이 아기들은 구분 어려움 → 수동 확인 옵션 필요 |
| **성능** | face-api.js는 사진당 ~1-3초 → 대량 업로드 시 백그라운드 처리 |

### 1.8 결론

```
✅ 가능합니다!

권장 전략:
- MVP: 수동 태깅으로 시작 (빠른 출시)
- v1.1: face-api.js 도입 (비용 없음)
- v2.0: AWS Rekognition (정확도 향상)

프로필 사진을 기준 얼굴로 사용하는 방식 👍
```

---

## 2. 무한대 사진/동영상 업로드

### 2.1 문제점 분석

"무한대"를 한번에 업로드하면 발생하는 문제:

| 문제 | 설명 |
|-----|------|
| **브라우저 메모리** | 1000장 × 5MB = 5GB → 브라우저 크래시 |
| **네트워크 타임아웃** | 오래 걸리면 연결 끊김 |
| **서버 메모리** | 동시에 대량 처리 시 OOM |
| **사용자 경험** | 진행률 모르면 불안 |
| **실패 처리** | 중간에 실패하면? 다시 전체 업로드? |

### 2.2 해결책: 청크 업로드 + 큐잉

```
┌─────────────────────────────────────────────────────────────────┐
│                    무한대 업로드 전략                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. 파일 선택         → 제한 없음 (1000장도 OK)                  │
│  2. 파일 큐에 추가    → 메모리에 파일 정보만 저장                │
│  3. 순차 업로드       → 한번에 3~5개씩 병렬 업로드               │
│  4. Direct Upload    → S3에 직접 업로드 (서버 부하 없음)         │
│  5. 진행률 표시       → "150/500 업로드 중..."                   │
│  6. 실패 시 재시도    → 해당 파일만 다시 시도                    │
│  7. 백그라운드 처리   → 앱 닫아도 계속 업로드 (Native)           │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 2.3 기술 구현

#### Active Storage Direct Upload (Rails)

```ruby
# config/storage.yml
amazon:
  service: S3
  access_key_id: <%= Rails.application.credentials.dig(:aws, :access_key_id) %>
  secret_access_key: <%= Rails.application.credentials.dig(:aws, :secret_access_key) %>
  region: ap-northeast-2
  bucket: moabom-photos

# Phase 1: Railway Volume (무료)
local:
  service: Disk
  root: <%= Rails.root.join("storage") %>
```

```ruby
# app/models/photo.rb
class Photo < ApplicationRecord
  has_one_attached :image

  # Direct Upload 사용 시 서버 메모리 사용 안 함
  # 클라이언트 → S3 직접 업로드
end
```

#### 프론트엔드 업로드 큐

```javascript
// app/javascript/controllers/bulk_upload_controller.js
import { Controller } from "@hotwired/stimulus"
import { DirectUpload } from "@rails/activestorage"

export default class extends Controller {
  static targets = ["input", "progress", "status"]
  static values = {
    concurrency: { type: Number, default: 3 }  // 동시 업로드 수
  }

  queue = []
  completed = 0
  failed = []

  selectFiles(event) {
    const files = Array.from(event.target.files)
    this.queue = files
    this.statusTarget.textContent = `${files.length}개 파일 선택됨`
  }

  async startUpload() {
    const total = this.queue.length
    this.completed = 0
    this.failed = []

    // 동시에 N개씩 업로드
    const chunks = this.chunkArray(this.queue, this.concurrencyValue)

    for (const chunk of chunks) {
      await Promise.all(chunk.map(file => this.uploadFile(file)))
      this.updateProgress(total)
    }

    this.showResult(total)
  }

  async uploadFile(file) {
    return new Promise((resolve) => {
      const upload = new DirectUpload(file, "/rails/active_storage/direct_uploads")

      upload.create((error, blob) => {
        if (error) {
          this.failed.push({ file, error })
        } else {
          this.completed++
          this.createPhotoRecord(blob)
        }
        resolve()
      })
    })
  }

  async createPhotoRecord(blob) {
    // 업로드 완료 후 Photo 레코드 생성
    await fetch("/photos", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
      },
      body: JSON.stringify({
        photo: { image: blob.signed_id }
      })
    })
  }

  updateProgress(total) {
    const percent = Math.round((this.completed / total) * 100)
    this.progressTarget.style.width = `${percent}%`
    this.statusTarget.textContent = `${this.completed}/${total} 업로드 중...`
  }

  chunkArray(array, size) {
    const chunks = []
    for (let i = 0; i < array.length; i += size) {
      chunks.push(array.slice(i, i + size))
    }
    return chunks
  }
}
```

### 2.4 Turbo Native에서 백그라운드 업로드

```swift
// iOS - BackgroundUploadManager.swift
class BackgroundUploadManager {
    static let shared = BackgroundUploadManager()

    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.background(withIdentifier: "com.moabom.upload")
        config.isDiscretionary = false
        config.sessionSendsLaunchEvents = true
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()

    func uploadPhotos(_ photos: [PHAsset]) {
        for photo in photos {
            // 백그라운드에서 계속 업로드
            let task = session.uploadTask(with: request, fromFile: fileURL)
            task.resume()
        }
    }
}
```

### 2.5 업로드 제한 권장사항

| 항목 | 권장값 | 이유 |
|-----|-------|------|
| **한번에 선택** | 무제한 | 파일 정보만 저장하므로 OK |
| **동시 업로드** | 3~5개 | 네트워크/메모리 균형 |
| **파일 크기** | 50MB/개 | 동영상 고려 |
| **일일 업로드** | 무제한 (가족용) | 스토리지 비용만 고려 |
| **재시도 횟수** | 3회 | 실패 시 자동 재시도 |

### 2.6 스토리지 비용 예측 (Phase 1)

```
가정:
- 가족 5명
- 월 500장 업로드
- 평균 3MB/장

월간 스토리지 증가: 500 × 3MB = 1.5GB/월
연간: 18GB

Railway Volume: 1GB 무료 → 곧 부족
→ Cloudflare R2 전환 권장 ($0.015/GB)
→ 연간 비용: ~$0.27 (거의 무료)
```

### 2.7 결론

```
✅ 가능합니다!

"무한대 업로드"는 실제로:
- 선택: 무제한 ✅
- 업로드: 순차 처리 (3~5개씩)
- 백그라운드: Native에서 지원
- 비용: 가족 사용 시 거의 무료

권장 구현:
1. Active Storage Direct Upload
2. 클라이언트 사이드 큐잉
3. 진행률 UI
4. Turbo Native 백그라운드 업로드
```

---

## 3. PRD 업데이트 제안

### 추가할 기능

```yaml
Phase 2 기능:
  F6. AI 자동 정리:
    - 얼굴 인식 → 아이별 앨범 (업데이트)
    + 프로필 사진 기반 얼굴 매칭
    + 자동 태깅 (face-api.js)
    + 태그별 필터링
    - 베스트샷 자동 선별
    - 흐린 사진 자동 분류

  F13. 대량 업로드 (NEW):
    - 무제한 파일 선택
    - 순차 업로드 (3~5개 병렬)
    - 진행률 표시
    - 실패 시 자동 재시도
    - Native 백그라운드 업로드
```

### MoSCoW 업데이트

| 우선순위 | 기능 | 이유 |
|---------|------|------|
| **Should** | 대량 업로드 | 사용 편의성 |
| **Should** | 수동 얼굴 태깅 | MVP 필수 |
| **Could** | 자동 얼굴 인식 | Phase 2 |

---

## 4. 요약

| 기능 | 가능 여부 | MVP | Phase 2 |
|-----|----------|-----|---------|
| **얼굴 자동 태깅** | ✅ 가능 | 수동 태깅 | face-api.js |
| **무한대 업로드** | ✅ 가능 | 순차 업로드 | 백그라운드 |

**둘 다 구현 가능하며, 단계별로 발전시키는 전략을 추천합니다!**
