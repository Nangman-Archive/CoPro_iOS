//
//  BlockedUserListTableViewCell.swift
//  CoPro
//
//  Created by 박신영 on 5/13/24.
//

import UIKit
import SnapKit
import Then
import KeychainSwift

class BlockedUserListTableViewCell: UITableViewCell {
   let keychain = KeychainSwift()
   
   //MARK: - UI Components
   
   private let nameLabel = UILabel().then {
      $0.setPretendardFont(text: "", size: 17, weight: .medium, letterSpacing: 1.22)
      $0.numberOfLines = 0
      $0.lineBreakMode = .byWordWrapping
   }
   
   private lazy var cancelButton = UIButton().then {
      $0.setTitle("해제", for: .normal)
      $0.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .regular)
      $0.setTitleColor(.red, for: .normal)
      $0.addTarget(self, action: #selector(didTapBlockCancelButton), for: .touchUpInside)
   }
   
   override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
      super.init(style: style, reuseIdentifier: reuseIdentifier)
      
      setLayout()
   }
   
   required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
   }
   
   private func setLayout() {
      addSubviews(nameLabel, cancelButton)
      
      // 댓글이 길어졌을 때도 괜찮으려면 높이설정하지 않는 것과, 좌우설정하여 넓이를 알 수 있도록 해야한다.
      nameLabel.snp.makeConstraints {
         $0.centerY.equalToSuperview()
         $0.leading.equalToSuperview().offset(16)
         $0.trailing.equalToSuperview().offset(-60)
      }
      
      cancelButton.snp.makeConstraints {
         $0.trailing.equalToSuperview().offset(-16)
         $0.height.equalTo(16)
         $0.centerY.equalToSuperview()
         $0.width.equalTo(30)
      }
   }
   
   override func setSelected(_ selected: Bool, animated: Bool) {
      super.setSelected(selected, animated: animated)
   }
   
   func configureCellBlockedUserList(_ data: BlockedDataModel) {
      nameLabel.text = data.name
   }
   
   @objc func didTapBlockCancelButton() {
   }
   
   
}

