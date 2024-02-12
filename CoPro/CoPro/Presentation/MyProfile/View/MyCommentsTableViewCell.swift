//
//  MyCommentsTableViewCell.swift
//  CoPro
//
//  Created by 박신영 on 2/2/24.
//

import UIKit
import SnapKit
import Then

class MyCommentsTableViewCell: UITableViewCell {
    
    //MARK: - UI Components

    private let contentLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 15)
    }
    
    private let commentTimeLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 13)
        $0.textColor = UIColor(hex: "6D6E71")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setLayout() {
        addSubviews(contentLabel, commentTimeLabel)
        
        contentLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.leading.equalToSuperview().offset(16)
        }
        
        commentTimeLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.bottom.equalToSuperview().offset(-8)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureCellWriteCommentbyMe(_ data: MyWrittenCommentDataModel) {
        contentLabel.text = data.content
        commentTimeLabel.text = data.getMyWrittenCommentDateString()
    }
}

