//
//  App.swfit
//

import Foundation
import UIKit

public struct App {

	public static var estSimulateur: Bool {
		return (TARGET_IPHONE_SIMULATOR != 0)
	}

	public static var estIpad: Bool {
		return (UIDevice.current.userInterfaceIdiom == .pad)
	}

	public static var estDebug: Bool {
		//au lieu de #if DEBUG, voir https://blog.wadetregaskis.com/if-debug-in-swift/
		return _isDebugAssertConfiguration()
	}


	public static var appGroup: String {
		return "group.com.skyriser.bingwallpapers"
	}

	public static var versionBundle: String {
		return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
	}
}

struct RuntimeError: Error {
	let message: String

	init(_ message: String) {
		self.message = message
	}

	public var localizedDescription: String {
		return message
	}
}
