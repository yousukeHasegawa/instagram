//
//  CommentViewController.swift
//  Instagram
//
//  Created by Yousuke Hasegawa on 2021/08/16.
//

import UIKit
import Firebase

class CommentViewController: UIViewController {
    @IBOutlet weak var commentTextField: UITextField!
    
    //投稿データを格納する
    //var postArray: [PostData] = []
    var postId:String!
    var userId:String!
    
    //更新されるコメントを格納する
    var updatedComment: String!

    
    override func viewDidLoad() {
        super.viewDidLoad()

    // Do any additional setup after loading the view.
    }
    
    //投稿ボタンが押されたときの動作
    @IBAction func tappedPlaneButton(_ sender: Any) {
        
        //コメントを更新する
        if updatedComment == "この投稿にコメントはありません。" {
            updatedComment = userId + "さんより：" + commentTextField.text! + "\n"
        } else {
            updatedComment = updatedComment + userId + "さんより：" + commentTextField.text! + "\n"
        }
        
        let postRef = Firestore.firestore().collection(Const.PostPath).document(postId)
        postRef.updateData(["comment": updatedComment!])

    }
}
    /*ß
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
