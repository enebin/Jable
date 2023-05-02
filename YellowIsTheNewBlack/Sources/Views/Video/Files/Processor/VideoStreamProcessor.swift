//
//  VideoStreamProcessor.swift
//  YellowIsTheNewBlack
//
//  Created by 이영빈 on 2023/04/24.
//

import UIKit
import AVFoundation

final class VideoStreamProcessor: NSObject {
    private let filePathManager: VideoFilePathManager

    private let captureSession: AVCaptureSession
    private let videoDataOutput: AVCaptureVideoDataOutput

    private var movieOutput: AVCaptureMovieFileOutput?

    private var videoURLs: [URL] = []
    private let jobQueue = OperationQueue()
    private let videoQueue = DispatchQueue(label: "videoQueue")

    // Internally shared props
    private var videoWriter: AVAssetWriter?
    private var videoWriterInput: AVAssetWriterInput?

    init(captureSession: AVCaptureSession, filePathManager: VideoFilePathManager = .init()) {
        self.filePathManager = filePathManager
        self.captureSession = captureSession
        self.videoDataOutput = AVCaptureVideoDataOutput()

        self.movieOutput = AVCaptureMovieFileOutput()

        // 작업큐는 셋업되기 전까지 잠궈놓음
        self.jobQueue.isSuspended = true

        super.init()
    }
}

extension VideoStreamProcessor {
    func setupCaptureSession() throws {
        captureSession.beginConfiguration()

        guard captureSession.isRunning else {
            throw VideoRecorderError.notConfigured
        }

        videoDataOutput.setSampleBufferDelegate(self, queue: videoQueue)
        if captureSession.canAddOutput(videoDataOutput) {
            captureSession.addOutput(videoDataOutput)
        }

        captureSession.commitConfiguration()

        // 이제 작업 실행 가능
        jobQueue.isSuspended = false
    }

    func startRecording() {
        jobQueue.addOperation { [self] in
            let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()
            ).appendingPathComponent("\(UUID().uuidString).mp4")

            videoURLs.append(tempURL)

            videoWriter = try? AVAssetWriter(outputURL: tempURL, fileType: .mp4)
            videoWriterInput = AVAssetWriterInput(mediaType: .video,
                                                  outputSettings: videoDataOutput.recommendedVideoSettingsForAssetWriter(writingTo: .mp4))

            videoWriterInput?.mediaTimeScale = CMTimeScale(bitPattern: 600)
            videoWriterInput?.expectsMediaDataInRealTime = true
            videoWriterInput?.transform = CGAffineTransform(rotationAngle: .pi/2)

            if
                let videoWriter = videoWriter,
                let videoWriterInput = videoWriterInput,
                videoWriter.canAdd(videoWriterInput)
            {
                videoWriter.add(videoWriterInput)
                videoWriter.startWriting()
                videoWriter.startSession(atSourceTime: CMTime.zero)
            }
        }
    }

    /// 프레임 기록을 잠시 멈춤. 저장은 하지 않음.
    func pauseRecording() async throws {
        videoWriterInput?.markAsFinished()
        videoWriterInput = nil

        guard let videoWriter else {
            throw VideoRecorderError.undableToSetExport
        }

        await videoWriter.finishWriting()
        print("\(#file)(\(#function)): Video segment temporarily saved to: \(videoURLs.last!)")

        self.videoWriter = nil
    }

    /// 기록을 멈추고 비디오를 저장
    func stopRecording() async throws -> URL {
        videoWriterInput = nil

        await videoWriter?.finishWriting()
        videoWriter = nil

        return try await mergeVideoSegments(urls: videoURLs)
    }
}

private extension VideoStreamProcessor {
    func mergeVideoSegments(urls: [URL]) async throws -> URL {
        let composition = AVMutableComposition()
        let videoTrack = composition.addMutableTrack(withMediaType: .video,
                                                     preferredTrackID: kCMPersistentTrackID_Invalid)
        var currentDuration = CMTime.zero
        for url in urls {
            let asset = AVURLAsset(url: url)
            print(asset.duration)

            guard let videoAssetTrack = asset.tracks(withMediaType: .video).first else { continue }
            do {
                try videoTrack?.insertTimeRange(CMTimeRange(start: .zero,
                                                            duration: asset.duration),
                                                of: videoAssetTrack,
                                                at: currentDuration)
                currentDuration = CMTimeAdd(currentDuration, asset.duration)
            } catch {
                print("Error merging video segments: \(error)")
            }
        }

        guard
            let exportSession = AVAssetExportSession(asset: composition,
                                                     presetName: AVAssetExportPresetHighestQuality)
        else {
            throw VideoRecorderError.undableToSetExport
        }

        let finalVideoURL = filePathManager.filePath

        exportSession.outputURL = finalVideoURL
        exportSession.outputFileType = .mp4
        await exportSession.export()

        return finalVideoURL
    }
}

extension VideoStreamProcessor: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        if let videoWriterInput = videoWriterInput, videoWriterInput.isReadyForMoreMediaData {
            videoWriterInput.append(sampleBuffer)
        }
    }
}

class VideoRecorder: NSObject {
    private let captureSession: AVCaptureSession
    private var assetWriter: AVAssetWriter?
    private var assetWriterInput: AVAssetWriterInput?

    private var currentRecordingURL: URL?
    private var isRecording = false

    private let videoQueue = DispatchQueue(label: "videoQueue")
    private let jobQueue = OperationQueue()

    init(captureSession: AVCaptureSession) {
        self.captureSession = captureSession
        jobQueue.isSuspended = true

        super.init()
    }

    func setupCaptureSession() throws {
        guard self.captureSession.isRunning else {
            throw VideoRecorderError.notConfigured
        }

        captureSession.beginConfiguration()
        defer {
            captureSession.commitConfiguration()
            jobQueue.isSuspended = false
        }

        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: videoQueue)
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
    }

    func startRecording(to url: URL) {
        guard !isRecording else { return }

        jobQueue.addOperation { [unowned self] in
            do {
                assetWriter = try AVAssetWriter(outputURL: url, fileType: .mp4)
                let videoSettings: [String: Any] = [
                    AVVideoCodecKey: AVVideoCodecType.h264,
                    AVVideoWidthKey: 1920,
                    AVVideoHeightKey: 1080
                ]
                assetWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
                assetWriterInput!.expectsMediaDataInRealTime = true
                assetWriterInput!.transform = CGAffineTransform(rotationAngle: .pi/2)

                if
                    let assetWriter = assetWriter,
                    let assetWriterInput = assetWriterInput,
                    assetWriter.canAdd(assetWriterInput) {
                    assetWriter.add(assetWriterInput)
                    isRecording = true
                }

                currentRecordingURL = url
                LoggingManager.logger.log(message: "Video recording started")
            } catch {
                LoggingManager.logger.log(error: error)
            }
        }
    }

    func stopRecording() async throws -> URL {
        guard isRecording, let currentRecordingURL else {
            backToInitialCondition()
            throw VideoRecorderError.undableToSetExport
        }

        assetWriterInput?.markAsFinished()
        await assetWriter?.finishWriting()

        LoggingManager.logger.log(message: "Video recording finished")
        backToInitialCondition()
        return currentRecordingURL
    }

    func pauseRecording() {
        guard isRecording else { return }
        isRecording = false
    }

    func resumeRecording() {
        guard isRecording == false else { return }
        isRecording = true
    }
}

private extension VideoRecorder {
    func backToInitialCondition() {
        assetWriter = nil
        assetWriterInput = nil
        self.isRecording = false
    }

    /// 현재 의도치 않은 동작으로 사용하지 않음.
    func getVideoTransform() -> CGAffineTransform {
        switch UIDevice.current.orientation {
        case .portrait:
            return .identity
        case .portraitUpsideDown:
            return CGAffineTransform(rotationAngle: .pi)
        case .landscapeLeft:
            return CGAffineTransform(rotationAngle: .pi/2)
        case .landscapeRight:
            return CGAffineTransform(rotationAngle: -.pi/2)
        default:
            return .identity
        }
    }
}

extension VideoRecorder: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard isRecording, let assetWriter, let assetWriterInput else { return }

        if assetWriter.status == .unknown {
            let presentationTimeStamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
            assetWriter.startWriting()
            assetWriter.startSession(atSourceTime: presentationTimeStamp)
        } else if assetWriter.status == .writing {
            if assetWriterInput.isReadyForMoreMediaData {
                assetWriterInput.append(sampleBuffer)
            }
        } else if assetWriter.status == .failed {
            LoggingManager.logger.log(error: assetWriter.error!)
            Task { try await stopRecording() }
        }
    }
}
