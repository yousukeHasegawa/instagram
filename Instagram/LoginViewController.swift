import UIKit
import Firebase
import SVProgressHUD

class LoginViewController: UIViewController {
    @IBOutlet weak var mailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var displayNameTextField: UITextField!
    
    //ログインボタンをタップした時に呼ばれるメソッド
    @IBAction func handleLoginButton(_ sender: Any) {
        if let address = mailAddressTextField.text, let password = passwordTextField.text{
            
            //アドレスとパスワードのいずれかでも入力されていない時は何もしない
            if address.isEmpty || password.isEmpty{
                SVProgressHUD.showError(withStatus: "ログインできません。必要項目を入力してください")
                return
            }
        
            //HUDで処理中を表示
            SVProgressHUD.show()
            
            Auth.auth().signIn(withEmail: address, password: password){ authResult, error in
                if let error = error {
                    print("DEBUG_PRINT: " + error.localizedDescription)
                    SVProgressHUD.showError(withStatus: "サインインに失敗しました。")
                    return
                }
                print("DEBUG_PRINT: ログインに成功しました。")
            
                //HUDを消す
                SVProgressHUD.dismiss()
                
                //画面を閉じてタブ画面に戻る
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
        
    //アカウント作成ボタンをタップした時に呼ばれるメソッド
    @IBAction func handleCreateAccountButton(_ sender: Any) {
        if let address = mailAddressTextField.text, let password = passwordTextField.text, let displayName = displayNameTextField.text{
            
            //アドレスとパスワードと表示名のいずれかでも入力されていない時は何もしない
            if address.isEmpty || password.isEmpty || displayName.isEmpty{
                print("DEBUG_PRINT:何かが空文字です")
                SVProgressHUD.showError(withStatus: "アカウントを作成できません。必要項目を入力してください")
                return
            }
            
            //HUDで処理中を表示
            SVProgressHUD.show()
            
            //アドレスとパスワードでユーザ作成。ユーザー作成に成功すると、自動的にログインする
            print(address)
            print(password)
            print(displayName)
            Auth.auth().createUser(withEmail: address, password: password){ authResult, error in
                if let error = error {
                    //エラーがあったら原因をprintして、returnすることで以降の距離を実行せずに終了する
                    print("DEBUG_PRINT2: " + error.localizedDescription)
                    SVProgressHUD.showError(withStatus: "ユーザ作成に失敗しました。")
                    return
                }
                print("DEBUG_PRINT: ユーザ作成に成功しました。 ")
               
                //表示名を設定する
                let user = Auth.auth().currentUser
                if let user = user {
                    let changeRequest = user.createProfileChangeRequest()
                    changeRequest.displayName = displayName
                    changeRequest.commitChanges { error in
                        if let error = error {
                            //プロフィールの更新でエラーが発生
                            print("DEBUG_PRINT: " + error.localizedDescription)
                            return
                        }
                        print("DEBUG_PRINT: [displayName = \(user.displayName!)]の設定に成功しました。")
                        
                        //HUDを消す
                        SVProgressHUD.dismiss()
                        
                        //画面を閉じてタブ画面に戻る
                        self.dismiss(animated: true, completion:nil)
                    }
                }
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
