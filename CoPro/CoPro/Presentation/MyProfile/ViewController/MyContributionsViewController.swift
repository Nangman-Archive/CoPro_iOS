//
//  WritebyMeViewController.swift
//  CoPro
//
//  Created by 박신영 on 2/1/24.
//

import UIKit
import SnapKit
import Then
import KeychainSwift

class MyContributionsViewController: BaseViewController {
   
   enum CellType {
      case post
      case comment
      case scrap
      case block
   }
   
   var activeCellType: CellType = .post
   // 처음에 post 타입으로 설정해두자. 왜냐 초기값 설정 안해, nil 값일 경우도 고려하는 것이 더 코드가 복잡해 지기 때문.
   
   private let keychain = KeychainSwift()
   private var myPostsData: [WritebyMeDataModel]?
   private var myCommentData: [MyWrittenCommentDataModel]?
   private var scrapPostData: [ScrapPostDataModel]?
   private var blockedData: [BlockedDataModel]?
   
   private lazy var tableView = UITableView().then({
      $0.showsVerticalScrollIndicator = false
      $0.separatorStyle = .singleLine
      $0.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
      $0.register(RelatedPostsToMeTableViewCell.self,
                  forCellReuseIdentifier:"RelatedPostsToMeTableViewCell")
      $0.register(MyCommentsTableViewCell.self,
                  forCellReuseIdentifier:"MyCommentsTableViewCell")
      $0.register(BlockedUserListTableViewCell.self, forCellReuseIdentifier: "BlockedUserListTableViewCell")
   })
   
   
   override func viewDidLoad() {
      super.viewDidLoad()
      self.navigationController?.setNavigationBarHidden(false, animated: true)
      view.backgroundColor = UIColor.White()
      // MARK: NavigationBar Custom Settings
      
      self.navigationItem.title = "관심 프로필"
      
      self.navigationController?.setNavigationBarHidden(false, animated: true)
      
      self.navigationController?.navigationBar.tintColor = UIColor.Black()
      
      
      // 왼쪽 여백 추가
      
      tableView.rowHeight = UITableView.automaticDimension
      
      switch activeCellType {
      case .post:
         tableView.estimatedRowHeight = 110
         self.navigationItem.title = "작성한 게시물"
         getWriteByMe()
         
      case .comment:
         tableView.estimatedRowHeight = 65
         self.navigationItem.title = "작성한 댓글"
         getMyWrittenComment()
         
      case .scrap:
         tableView.estimatedRowHeight = 110
         self.navigationItem.title = "저장한 게시물"
         getScrapPost()
         
      case .block:
         tableView.estimatedRowHeight = 65
         self.navigationItem.title = "차단한 유저"
         getBlockedUserList()
      }
      
      setDelegate()
   }
   
   // Navigation Controller
   func popViewController() {
      self.navigationController?.popViewController(animated: true)
   }
   
   override func setLayout() {
      view.addSubview(tableView)
      tableView.snp.makeConstraints {
         $0.top.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
      }
   }
   
   private func getWriteByMe() {
      if let token = self.keychain.get("accessToken") {
         MyProfileAPI.shared.getWritebyMe(token: token) { result in
            switch result {
            case .success(let data):
               if let data = data as? WritebyMeDTO {
                  self.myPostsData = data.data.content.map {
                     return WritebyMeDataModel(boardId: $0.boardId, title: $0.title, nickName: $0.nickName, createAt: $0.createAt, count: $0.count, heart: $0.heart, imageURL: $0.imageURL ?? "", commentCount: $0.commentCount, category: $0.category)
                  }
                  print("🌊🌊🌊🌊🌊🌊🌊🌊myPostsData?.count : \(String(describing: self.myPostsData?.count))🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊")
                  
                  DispatchQueue.main.async {
                     self.tableView.reloadData()
                     if self.myPostsData?.count == 0 {
                        // contents가 비어있을 때 메시지 라벨을 추가합니다.
                        let messageLabel = UILabel().then {
                           $0.setPretendardFont(text: "작성한 게시물이 없어요!", size: 17, weight: .regular, letterSpacing: 1.25)
                           $0.textColor = .black
                           $0.textAlignment = .center
                        }
                        
                        let imageView = UIImageView(image: UIImage(named: "card_coproLogo")) // 이미지 생성
                        imageView.contentMode = .center // 이미지가 중앙에 위치하도록 설정
                        
                        let stackView = UIStackView(arrangedSubviews: [imageView, messageLabel]) // 이미지와 라벨을 포함하는 스택 뷰 생성
                        stackView.axis = .vertical // 세로 방향으로 정렬
                        stackView.alignment = .center // 가운데 정렬
                        stackView.spacing = 10 // 이미지와 라벨 사이의 간격 설정
                        
                        self.tableView.backgroundView = UIView() // 배경 뷰 생성
                        
                        if let backgroundView = self.tableView.backgroundView {
                           backgroundView.addSubview(stackView) // 스택 뷰를 배경 뷰에 추가
                           
                           stackView.snp.makeConstraints {
                              $0.centerX.equalTo(backgroundView) // 스택 뷰의 가로 중앙 정렬
                              $0.centerY.equalTo(backgroundView) // 스택 뷰의 세로 중앙 정렬
                           }
                        }
                     } else {
                        // contents가 비어있지 않을 때 메시지 라벨을 제거합니다.
                        self.tableView.backgroundView = nil
                        self.view.backgroundColor = .white
                     }
                  }
               } else {
                  print("Failed to decode the response.")
               }
               
            case .requestErr(let message):
               print("Error : \(message)")
            case .pathErr, .serverErr, .networkFail:
               print("another Error")
            default:
               break
            }
            
         }
      }
   }
   
   private func getMyWrittenComment() {
      if let token = self.keychain.get("accessToken") {
         MyProfileAPI.shared.getMyWrittenComment(token: token) { result in
            switch result {
            case .success(let data):
               if let data = data as? MyWrittenCommentDTO {
                  self.myCommentData = data.data.content.map {
                     return MyWrittenCommentDataModel(
                        parentID: $0.parentID,
                        commentID: $0.commentID,
                        boardID: $0.boardID,
                        content: $0.content,
                        createAt: $0.createAt,
                        writer: MyWrittenCommentDataModelWriter(from: $0.writer) // 수정된 부분
                     )
                  }
                  DispatchQueue.main.async {
                     self.tableView.reloadData()
                     if self.myCommentData?.count == 0 {
                        // contents가 비어있을 때 메시지 라벨을 추가합니다.
                        let messageLabel = UILabel().then {
                           $0.setPretendardFont(text: "작성한 댓글이 없어요!", size: 17, weight: .regular, letterSpacing: 1.25)
                           $0.textColor = .black
                           $0.textAlignment = .center
                        }
                        
                        let imageView = UIImageView(image: UIImage(named: "card_coproLogo")) // 이미지 생성
                        imageView.contentMode = .center // 이미지가 중앙에 위치하도록 설정
                        
                        let stackView = UIStackView(arrangedSubviews: [imageView, messageLabel]) // 이미지와 라벨을 포함하는 스택 뷰 생성
                        stackView.axis = .vertical // 세로 방향으로 정렬
                        stackView.alignment = .center // 가운데 정렬
                        stackView.spacing = 10 // 이미지와 라벨 사이의 간격 설정
                        
                        self.tableView.backgroundView = UIView() // 배경 뷰 생성
                        
                        if let backgroundView = self.tableView.backgroundView {
                           backgroundView.addSubview(stackView) // 스택 뷰를 배경 뷰에 추가
                           
                           stackView.snp.makeConstraints {
                              $0.centerX.equalTo(backgroundView) // 스택 뷰의 가로 중앙 정렬
                              $0.centerY.equalTo(backgroundView) // 스택 뷰의 세로 중앙 정렬
                           }
                        }
                     } else {
                        // contents가 비어있지 않을 때 메시지 라벨을 제거합니다.
                        self.tableView.backgroundView = nil
                        self.view.backgroundColor = .white
                     }
                     
                  }
               } else {
                  print("Failed to decode the response.")
               }
               
            case .requestErr(let message):
               print("Error : \(message)")
            case .pathErr, .serverErr, .networkFail:
               print("another Error")
            default:
               break
            }
            
         }
      }
   }
   
   private func getScrapPost() {
      if let token = self.keychain.get("accessToken") {
         MyProfileAPI.shared.getScrapPost(token: token) { result in
            switch result {
            case .success(let data):
               if let data = data as? ScrapPostDTO {
                  self.scrapPostData = data.data.content.map {
                     return ScrapPostDataModel(boardID: $0.boardID, title: $0.title, count: $0.count, createAt: $0.createAt, heart: $0.heart, imageURL: $0.imageURL ?? "", nickName: $0.nickName, commentCount: $0.commentCount, category: $0.category)
                  }
                  DispatchQueue.main.async {
                     self.tableView.reloadData()
                     if self.scrapPostData?.count == 0 {
                        // contents가 비어있을 때 메시지 라벨을 추가합니다.
                        let messageLabel = UILabel().then {
                           $0.setPretendardFont(text: "저장한 게시물이 없어요!", size: 17, weight: .regular, letterSpacing: 1.25)
                           $0.textColor = .black
                           $0.textAlignment = .center
                        }
                        
                        let imageView = UIImageView(image: UIImage(named: "card_coproLogo")) // 이미지 생성
                        imageView.contentMode = .center // 이미지가 중앙에 위치하도록 설정
                        
                        let stackView = UIStackView(arrangedSubviews: [imageView, messageLabel]) // 이미지와 라벨을 포함하는 스택 뷰 생성
                        stackView.axis = .vertical // 세로 방향으로 정렬
                        stackView.alignment = .center // 가운데 정렬
                        stackView.spacing = 10 // 이미지와 라벨 사이의 간격 설정
                        
                        self.tableView.backgroundView = UIView() // 배경 뷰 생성
                        
                        if let backgroundView = self.tableView.backgroundView {
                           backgroundView.addSubview(stackView) // 스택 뷰를 배경 뷰에 추가
                           
                           stackView.snp.makeConstraints {
                              $0.centerX.equalTo(backgroundView) // 스택 뷰의 가로 중앙 정렬
                              $0.centerY.equalTo(backgroundView) // 스택 뷰의 세로 중앙 정렬
                           }
                        }
                     } else {
                        // contents가 비어있지 않을 때 메시지 라벨을 제거합니다.
                        self.tableView.backgroundView = nil
                        self.view.backgroundColor = .white
                     }
                  }
               } else {
                  print("Failed to decode the response.")
               }
               
            case .requestErr(let message):
               print("Error : \(message)")
            case .pathErr, .serverErr, .networkFail:
               print("another Error")
            default:
               break
            }
            
         }
      }
   }
   
   private func getBlockedUserList() {
      guard let token = self.keychain.get("accessToken") else {
         print("No accessToken found in keychain.")
         return
      }
      
      MyProfileAPI.shared.getBlockedUserList(token: token) { result in
         switch result {
         case .success(let data):
            DispatchQueue.main.async {
               if let data = data as? BlockedDTO {
                  self.blockedData = data.data.content.map {
                     return BlockedDataModel(blockedMemberID: $0.blockedMemberID, name: $0.name, email: $0.email, picture: $0.picture, occupation: $0.occupation, language: $0.language, career: $0.career, gitHubURL: $0.gitHubURL, isBlocked: $0.isBlocked)
                  }
                  print("🌊🌊🌊🌊🌊🌊🌊🌊blockedData?.count : \(String(describing: self.blockedData?.count))🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊")
                  
                  DispatchQueue.main.async {
                     self.tableView.reloadData()
                     if self.blockedData?.count == 0 {
                        // contents가 비어있을 때 메시지 라벨을 추가합니다.
                        let messageLabel = UILabel().then {
                           $0.setPretendardFont(text: "차단한 유저가 없어요!", size: 17, weight: .regular, letterSpacing: 1.25)
                           $0.textColor = .black
                           $0.textAlignment = .center
                        }
                        
                        let imageView = UIImageView(image: UIImage(named: "card_coproLogo")) // 이미지 생성
                        imageView.contentMode = .center // 이미지가 중앙에 위치하도록 설정
                        
                        let stackView = UIStackView(arrangedSubviews: [imageView, messageLabel]) // 이미지와 라벨을 포함하는 스택 뷰 생성
                        stackView.axis = .vertical // 세로 방향으로 정렬
                        stackView.alignment = .center // 가운데 정렬
                        stackView.spacing = 10 // 이미지와 라벨 사이의 간격 설정
                        
                        self.tableView.backgroundView = UIView() // 배경 뷰 생성
                        
                        if let backgroundView = self.tableView.backgroundView {
                           backgroundView.addSubview(stackView) // 스택 뷰를 배경 뷰에 추가
                           
                           stackView.snp.makeConstraints {
                              $0.centerX.equalTo(backgroundView) // 스택 뷰의 가로 중앙 정렬
                              $0.centerY.equalTo(backgroundView) // 스택 뷰의 세로 중앙 정렬
                           }
                        }
                     } else {
                        // contents가 비어있지 않을 때 메시지 라벨을 제거합니다.
                        self.tableView.backgroundView = nil
                        self.view.backgroundColor = .white
                     }
                  }
               } else {
                  print("Failed to decode the response.")
               }
            }
         case .requestErr(let message):
            // 요청 에러인 경우
            print("Error : \(message)")
         case .pathErr, .serverErr, .networkFail:
            // 다른 종류의 에러인 경우
            print("Another Error")
         default:
            break
         }
      }
   }
}

extension MyContributionsViewController: UITableViewDelegate, UITableViewDataSource {
   
   private func setDelegate() {
      tableView.delegate = self
      tableView.dataSource = self
   }
   
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      switch activeCellType {
      case .post:
         return myPostsData?.count ?? 0
         
      case .comment:
         return myCommentData?.count ?? 0
         
      case .scrap:
         return scrapPostData?.count ?? 0
         
      case .block:
         return blockedData?.count ?? 0
      }
   }
   
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      switch activeCellType {
      case .post:
         guard let cell = tableView.dequeueReusableCell(withIdentifier: "RelatedPostsToMeTableViewCell", for: indexPath) as? RelatedPostsToMeTableViewCell
         else {
            return UITableViewCell()
         }
         let reverseIndex = (myPostsData?.count ?? 0) - 1 - indexPath.row
         let post = myPostsData?[reverseIndex]
         cell.configureCellWritebyMe(post!)
         var postCategoryType = post?.category
         if postCategoryType == "프로젝트" {
            cell.commentCountIcon.removeFromSuperview()
            cell.commentCountLabel.removeFromSuperview()
            cell.likeCountIcon.removeFromSuperview()
            cell.likeCountLabel.removeFromSuperview()
            cell.sawPostIcon.snp.remakeConstraints {
               $0.top.equalTo(cell.writerNameLabel.snp.bottom).offset(6)
               $0.leading.equalTo(cell.postTitleLabel.snp.leading)
               $0.bottom.equalToSuperview()
               $0.width.equalTo(20)
               $0.height.equalTo(20)
            }
            cell.sawPostLabel.snp.remakeConstraints {
               $0.leading.equalTo(cell.sawPostIcon.snp.trailing).offset(4)
               $0.centerY.equalTo(cell.sawPostIcon.snp.centerY)
            }
         }
         cell.selectionStyle = .none
         
         
         return cell
         
      case .scrap:
         guard let cell = tableView.dequeueReusableCell(withIdentifier: "RelatedPostsToMeTableViewCell", for: indexPath) as? RelatedPostsToMeTableViewCell
         else {
            return UITableViewCell()
         }
         print("scrap입장")
         let reverseIndex = (scrapPostData?.count ?? 0) - 1 - indexPath.row
         let scrapPost = scrapPostData?[reverseIndex]
         cell.configureCellScrapPost(scrapPost!)
         var postCategoryType = scrapPost?.category
         if postCategoryType == "프로젝트" {
            cell.commentCountIcon.removeFromSuperview()
            cell.commentCountLabel.removeFromSuperview()
            cell.likeCountIcon.removeFromSuperview()
            cell.likeCountLabel.removeFromSuperview()
            cell.sawPostIcon.snp.remakeConstraints {
               $0.top.equalTo(cell.writerNameLabel.snp.bottom).offset(6)
               $0.leading.equalTo(cell.postTitleLabel.snp.leading)
               $0.bottom.equalToSuperview()
               $0.width.equalTo(20)
               $0.height.equalTo(20)
            }
            cell.sawPostLabel.snp.remakeConstraints {
               $0.leading.equalTo(cell.sawPostIcon.snp.trailing).offset(4)
               $0.centerY.equalTo(cell.sawPostIcon.snp.centerY)
            }
         }
         cell.selectionStyle = .none
         return cell
         
      case .comment:
         guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyCommentsTableViewCell", for: indexPath) as? MyCommentsTableViewCell
         else {
            return UITableViewCell()
         }
         let reverseIndex = (myCommentData?.count ?? 0) - 1 - indexPath.row
         let comment = myCommentData?[reverseIndex]
         cell.configureCellWriteCommentbyMe(comment!)
         cell.selectionStyle = .none
         return cell
         
      case .block:
         guard let cell = tableView.dequeueReusableCell(withIdentifier: "BlockedUserListTableViewCell", for: indexPath) as? BlockedUserListTableViewCell
         else {
            return UITableViewCell()
         }
         let reverseIndex = (blockedData?.count ?? 0) - 1 - indexPath.row
         let comment = blockedData?[reverseIndex]
         cell.configureCellBlockedUserList(comment!)
         cell.selectionStyle = .none
         return cell
      }
   }
   
   // 셀 클릭시 이벤트 (추후 detailVC에서 분기처리 필요)
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      switch activeCellType {
      case .post:
         print("post")
         let detailVC = DetailBoardViewController()
         detailVC.delegate = self
         let reverseIndex = (myPostsData?.count ?? 0) - 1 - indexPath.row
         if let id = self.myPostsData?[reverseIndex].boardId {
            detailVC.postId = id
            navigationController?.pushViewController(detailVC, animated: true)
         }
         
      case .scrap:
         print("scrap")
         let detailVC = DetailBoardViewController()
         detailVC.delegate = self
         let reverseIndex = (scrapPostData?.count ?? 0) - 1 - indexPath.row
         if let id = self.scrapPostData?[reverseIndex].boardID {
            detailVC.postId = id
            navigationController?.pushViewController(detailVC, animated: true)
         }
         
      case .comment:
         print("comment")
         let detailVC = DetailBoardViewController()
         detailVC.delegate = self
         let reverseIndex = (myCommentData?.count ?? 0) - 1 - indexPath.row
         if let id = self.myCommentData?[reverseIndex].boardID {
            detailVC.postId = id
            navigationController?.pushViewController(detailVC, animated: true)
         }
         
      case .block:
         print("cancelBlock")
         let reverseIndex = (blockedData?.count ?? 0) - 1 - indexPath.row
         if let name = self.blockedData?[reverseIndex].name {
            DispatchQueue.main.async {
               self.showAlert(title: "차단을 해제하시겠습니까?",
                              cancelButtonName: "취소",
                              confirmButtonName: "해제",
                              confirmButtonCompletion: { [self] in
                  cancelBlock(nickname: name)
               })
               
            }
         }
         print("끝")
      }
   }
   
   func cancelBlock(nickname: String) {
      if let token = self.keychain.get("accessToken") {
         print("\(token)")
         BoardAPI.shared.cancelBlock(token: token, nickname: nickname) { result in
            switch result {
            case .success(let data):
               print("cancel success")
               print(data)
               self.getBlockedUserList()
               
            case .requestErr(let message):
               print("Request error: \(message)")
            case .pathErr:
               print("Path error")
               
            case .serverErr:
               print("Server error")
               
            case .networkFail:
               print("Network failure")
               
            default:
               break
            }
         }
      }
   }
   
   @objc func backButtonTapped() {
      
      if self.navigationController == nil {
         self.dismiss(animated: true, completion: nil)
      } else {
         self.navigationController?.popViewController(animated: true)
      }
   }
}

extension MyContributionsViewController: DetailViewControllerDelegate {
   func didDeletePost() {
      switch activeCellType {
      case .post:
         tableView.estimatedRowHeight = 110
         self.navigationItem.title = "작성한 게시물"
         getWriteByMe()
         
      case .comment:
         tableView.estimatedRowHeight = 65
         self.navigationItem.title = "작성한 댓글"
         getMyWrittenComment()
         
      case .scrap:
         tableView.estimatedRowHeight = 110
         self.navigationItem.title = "저장한 게시물"
         getScrapPost()
         
      default:
         print("")
      }
   }
}
