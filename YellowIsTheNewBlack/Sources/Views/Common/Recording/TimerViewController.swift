//
//  TimerViewController.swift
//  YellowIsTheNewBlack
//
//  Created by 이영빈 on 2023/04/19.
//

import UIKit
import SnapKit

class TimerViewController: UIViewController {
    private let timeFormatter =  ElapsedTimeFormatter()

    private var timer: Timer?
    private var viewObservation: NSKeyValueObservation?
    private var elapsedTime: Int = 0

    // MARK: View components
    lazy var elapsedTimeLabel = UILabel().then {
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 17, weight: .bold)
        $0.text = timeFormatter.formatTime(0)
    }

    lazy var redDotView = UIView().then {
        $0.backgroundColor = .red
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewObservation = observeViewHiddenStatus()

        setViewComponents()
        startTimer()
    }
}

private extension TimerViewController {
    func observeViewHiddenStatus() -> NSKeyValueObservation {
        return self.observe(\.view?.isHidden, options: [.old, .new], changeHandler: { mySelf, isHidden in
            if isHidden.newValue == false {
                mySelf.startTimer()
            } else {
                mySelf.stopTimer()
            }
        })
    }

    func setViewComponents() {
        let stackView = UIStackView(arrangedSubviews: [redDotView, elapsedTimeLabel])
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .top

        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
        }

        redDotView.snp.makeConstraints { make in
            make.width.height.equalTo(elapsedTimeLabel.snp.height)
        }
    }

    // Timer related
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }

            self.elapsedTime += 1
            self.elapsedTimeLabel.text = self.timeFormatter.formatTime(self.elapsedTime)
        }
    }

    func stopTimer() {
        elapsedTime = 0
        elapsedTimeLabel.text = timeFormatter.formatTime(elapsedTime)

        timer?.invalidate()
        timer = nil

        view.setNeedsLayout()
    }
}

private struct ElapsedTimeFormatter {
    private let formatter: DateComponentsFormatter

    func formatTime(_ seconds: Int) -> String {
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad

        return formatter.string(from: TimeInterval(seconds)) ?? "00:00:00"
    }

    init() {
        self.formatter = DateComponentsFormatter()
    }
}
