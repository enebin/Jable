//
//  VideoStreamProcessor.swift
//  YellowIsTheNewBlack
//
//  Created by 이영빈 on 2023/04/24.
//

import UIKit
import AVFoundation

final class VideoStreamProcessor: NSObject {
    private let captureSession: AVCaptureSession
    private let videoDataOutput: AVCaptureVideoDataOutput
    private var videoURLs: [URL] = []
    
    private let videoQueue = DispatchQueue(label: "videoQueue")
    
    // Internally shared props
    private var videoWriter: AVAssetWriter?
    private var videoWriterInput: AVAssetWriterInput?

    init?(captureSession: AVCaptureSession,
         videoWriterInput: AVAssetWriterInput) {
        self.captureSession = captureSession
        self.videoDataOutput = AVCaptureVideoDataOutput()
        
        super.init()
        try? setupCaptureSession()
    }
}

extension VideoStreamProcessor {
    func startRecording() {
        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(UUID().uuidString).mp4")
        videoURLs.append(tempURL)
        videoWriter = try? AVAssetWriter(outputURL: tempURL, fileType: .mp4)
        videoWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: 1920,
            AVVideoHeightKey: 1080
        ])
        
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
    
    /// 프레임 기록을 잠시 멈춤. 저장은 하지 않음.
    func pauseRecording() {
        videoWriterInput = nil
        videoWriter?.finishWriting(completionHandler: {
            print("Video segment saved to: \(self.videoURLs.last!)")
        })
        videoWriter = nil
    }

    /// 기록을 멈추고 비디오를 저장
    func stopRecording() {
        videoWriterInput = nil
        videoWriter?.finishWriting(completionHandler: { [weak self] in
            DispatchQueue.global(qos: .utility).async {
                self?.mergeVideoSegments()
            }
        })
        videoWriter = nil
    }
}

private extension VideoStreamProcessor {
    func setupCaptureSession() throws {
        guard captureSession.isRunning else {
            throw VideoRecorderError.notConfigured
        }

        videoDataOutput.setSampleBufferDelegate(self, queue: videoQueue)
        if captureSession.canAddOutput(videoDataOutput) {
            captureSession.addOutput(videoDataOutput)
        }
    }
    
    func mergeVideoSegments() {
        let composition = AVMutableComposition()
        let videoTrack = composition.addMutableTrack(withMediaType: .video,
                                                     preferredTrackID: kCMPersistentTrackID_Invalid)

        var currentDuration = CMTime.zero
        for url in videoURLs {
            let asset = AVURLAsset(url: url)
            guard let videoAssetTrack = asset.tracks(withMediaType: .video).first else { continue }
            do {
                try videoTrack?.insertTimeRange(CMTimeRange(start: .zero, duration: asset.duration), of: videoAssetTrack, at: currentDuration)
                currentDuration = CMTimeAdd(currentDuration, asset.duration)
            } catch {
                print("Error merging video segments: \(error)")
            }
        }

        guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
            return
        }

        let finalVideoURL = URL(
            fileURLWithPath: NSTemporaryDirectory()
        ).appendingPathComponent("final_\(UUID().uuidString).mp4")
        
        exportSession.outputURL = finalVideoURL
        exportSession.outputFileType = .mp4
        exportSession.exportAsynchronously {
            DispatchQueue.main.async {
                switch exportSession.status {
                case .completed:
                    print("Merged video saved to: \(finalVideoURL)")
                case .failed, .cancelled:
                    print("Error merging video segments: \(exportSession.error?.localizedDescription ?? "unknown error")")
                default:
                    break
                }
            }
        }
    }
}

extension VideoStreamProcessor: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        if
            let videoWriterInput = videoWriterInput,
            videoWriterInput.isReadyForMoreMediaData
        {
            videoWriterInput.append(sampleBuffer)
        }
    }
}
