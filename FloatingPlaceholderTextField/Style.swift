//
//  Copyright © 2014-2020 Reactive Reality. All rights reserved.
//

import UIKit

enum TextFieldStyle {
    case text(placeholder: String?)
    case numbers(placeholder: String?)
    case email
    case password(placeholder: String? = "Password")
    case name

    var placeholder: String? {
        switch self {
        case .email: return "Email"
        case .name: return "Name"
        case .text(let placeholder), .numbers(let placeholder), .password(let placeholder): return placeholder
        }
    }

    var capitalization: UITextAutocapitalizationType {
        switch self {
        case .text: return .sentences
        case .name: return .words
        case .email, .numbers, .password: return .none
        }
    }

    var keyboardType: UIKeyboardType {
        switch self {
        case .email: return .emailAddress
        case .password: return .asciiCapable
        case .name, .text: return .default
        case .numbers: return .numberPad
        }
    }

    var secureInput: Bool {
        switch self {
        case .password: return true
        default: return false
        }
    }
}
