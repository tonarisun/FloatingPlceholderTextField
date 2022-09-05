//
//  Copyright © 2014-2020 Reactive Reality. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var textFieldView: FloatingPlaceholderTextField!
    @IBOutlet var textFieldView1: FloatingPlaceholderTextField!
    @IBOutlet var textFieldView2: FloatingPlaceholderTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textFieldView.configure(style: .name, value: "Default value", isDefaultValue: true)
        textFieldView1.configure(style: .password())
        textFieldView2.configure(style: .numbers(placeholder: "Enter number"))
    }

    @IBAction func tapButton(_ sender: Any) {
        self.view.endEditing(true)
        if (textFieldView1.textValue ?? "").isEmpty {
            textFieldView1.setErrorState()
        }
    }
}

