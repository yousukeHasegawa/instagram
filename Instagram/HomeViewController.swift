import UIKit
import Firebase

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    //投稿データを格納する配列
    var postArray: [PostData] = []
    
    //Firebaseのリスナー
    var listener: ListenerRegistration?
    
    //segueにコメントデータを投入するのに必要な情報
    var postID: String!
    var comment: String!
    
    //ユーIDを格納する情報
    var userID: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //カスタムセルを登録する
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
    }
    
    
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: viewWillAppear")
        //ログイン済みか確認
        if Auth.auth().currentUser != nil {
            //listenerを登録して投稿データの更新を監視する
            let postsRef = Firestore.firestore().collection(Const.PostPath).order(by: "date", descending: true)
            listener = postsRef.addSnapshotListener() {(querySnapshot, error) in
                if let error = error{
                    print("DEBUG_PRINT: snapshotの取得が失敗しました。\(error)")
                    return
                }
                //取得したdocumentを元にPostDataを作成し、postArrayの配列にする。

                self.postArray = querySnapshot!.documents.map{ document in
                    print("DEBUG_PRINT: document取得\(document.documentID)")
                    
                    let postData = PostData(document: document)
                    return postData
                }
                //TableViewの表示を更新する

                self.tableView.reloadData()

            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("DEBUG_PRINT: viewWillDisappear")
        //listenerを削除して監視を停止する
        listener?.remove()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //セルを取得してデータを設定する
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostTableViewCell
        cell.setPostData(postArray[indexPath.row])

        //セル内のボタンのアクションをソースコードで設定する
        cell.likeButton.addTarget(self, action:#selector(handlelikeButton(_:forEvent:)), for: .touchUpInside)
        cell.commentButton.addTarget(self, action:#selector(handleCommentButton(_:forEvent:)), for: .touchUpInside)

        
        return cell
    }
    
    //セル内のボタンがタップされた時に呼ばれるメソッド

    @objc func handlelikeButton(_ sender: UIButton, forEvent event: UIEvent){

        //タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        //配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]
        
        //likesを更新する
        print("DEBUG_PRINT: likeボタンがタップされました。")
        if let myid = Auth.auth().currentUser?.uid{
                // 更新データを作成する
            var updateValue: FieldValue
                
            if postData.isLiked{
                //すでにいいねをしている場合は、いいね解除のためmyidを取り除く更新データを作成
                updateValue = FieldValue.arrayRemove([myid])
            }else{
                //今回新たにいいねを押した場合は、myidを追加する更新データを作成
                updateValue = FieldValue.arrayUnion([myid])
            }
            //likesに更新データを書き込む
            let postRef = Firestore.firestore().collection(Const.PostPath).document(postData.id)
            postRef.updateData(["likes": updateValue])
        }
    }
    //コメントボタンがタップされた時に呼ばれるメソッド
    @objc func handleCommentButton(_ sender: UIButton, forEvent event: UIEvent){//
        

        //タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)

        //配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]
 
        print("DEBUG_PRINT: Commentボタンがタップされました。")
 
            //遷移先のデータを特定する
            postID = postData.id
            comment = postData.comment
            
            //ユーザを特定
            userID = Auth.auth().currentUser?.displayName
            
            //Segue画面遷移
            performSegue(withIdentifier: "Comment", sender: (Any).self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // segueから遷移先のResultViewControllerを取得する
        
        let commentViewController:CommentViewController = segue.destination as! CommentViewController
        
        commentViewController.postId = postID
        commentViewController.userId = userID
        commentViewController.updatedComment = comment
    }
    
    
    
    @IBAction func unwind(_ segue: UIStoryboardSegue) {
    // 他の画面から segue を使って戻ってきた時に呼ばれる
    }
}
