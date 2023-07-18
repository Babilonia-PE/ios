// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(OSX)
  import AppKit.NSFont
#elseif os(iOS) || os(tvOS) || os(watchOS)
  import UIKit.UIFont
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "FontConvertible.Font", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias Font = FontConvertible.Font

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Fonts

// swiftlint:disable identifier_name line_length type_body_length
internal enum FontFamily {
  internal enum AvenirLTStd {
    internal static let _95Black = FontConvertible(name: "AvenirLTStd-Black", family: "Avenir LT Std", path: "AvenirLTStd-Black.otf")
    internal static let _95BlackOblique = FontConvertible(name: "AvenirLTStd-BlackOblique", family: "Avenir LT Std", path: "AvenirLTStd-BlackOblique.otf")
    internal static let _45Book = FontConvertible(name: "AvenirLTStd-Book", family: "Avenir LT Std", path: "AvenirLTStd-Book.otf")
    internal static let _45BookOblique = FontConvertible(name: "AvenirLTStd-BookOblique", family: "Avenir LT Std", path: "AvenirLTStd-BookOblique.otf")
    internal static let _85Heavy = FontConvertible(name: "AvenirLTStd-Heavy", family: "Avenir LT Std", path: "AvenirLTStd-Heavy.otf")
    internal static let _85HeavyOblique = FontConvertible(name: "AvenirLTStd-HeavyOblique", family: "Avenir LT Std", path: "AvenirLTStd-HeavyOblique.otf")
    internal static let _35Light = FontConvertible(name: "AvenirLTStd-Light", family: "Avenir LT Std", path: "AvenirLTStd-Light.otf")
    internal static let _35LightOblique = FontConvertible(name: "AvenirLTStd-LightOblique", family: "Avenir LT Std", path: "AvenirLTStd-LightOblique.otf")
    internal static let _65Medium = FontConvertible(name: "AvenirLTStd-Medium", family: "Avenir LT Std", path: "AvenirLTStd-Medium.otf")
    internal static let _65MediumOblique = FontConvertible(name: "AvenirLTStd-MediumOblique", family: "Avenir LT Std", path: "AvenirLTStd-MediumOblique.otf")
    internal static let _55Oblique = FontConvertible(name: "AvenirLTStd-Oblique", family: "Avenir LT Std", path: "AvenirLTStd-Oblique.otf")
    internal static let _55Roman = FontConvertible(name: "AvenirLTStd-Roman", family: "Avenir LT Std", path: "AvenirLTStd-Roman.otf")
    internal static let all: [FontConvertible] = [_95Black, _95BlackOblique, _45Book, _45BookOblique, _85Heavy, _85HeavyOblique, _35Light, _35LightOblique, _65Medium, _65MediumOblique, _55Oblique, _55Roman]
  }
  internal enum SamsungSharpSans {
    internal static let regular = FontConvertible(name: "SamsungSharpSans", family: "Samsung Sharp Sans", path: "samsungsharpsans.otf")
    internal static let bold = FontConvertible(name: "SamsungSharpSans-Bold", family: "Samsung Sharp Sans", path: "samsungsharpsans-bold.otf")
    internal static let medium = FontConvertible(name: "SamsungSharpSans-Medium", family: "Samsung Sharp Sans", path: "samsungsharpsans-medium.otf")
    internal static let all: [FontConvertible] = [regular, bold, medium]
  }
  internal static let allCustomFonts: [FontConvertible] = [AvenirLTStd.all, SamsungSharpSans.all].flatMap { $0 }
  internal static func registerAllCustomFonts() {
    allCustomFonts.forEach { $0.register() }
  }
}
// swiftlint:enable identifier_name line_length type_body_length

// MARK: - Implementation Details

internal struct FontConvertible {
  internal let name: String
  internal let family: String
  internal let path: String

  #if os(OSX)
  internal typealias Font = NSFont
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Font = UIFont
  #endif

  internal func font(size: CGFloat) -> Font {
    guard let font = Font(font: self, size: size) else {
      fatalError("Unable to initialize font '\(name)' (\(family))")
    }
    return font
  }

  internal func register() {
    // swiftlint:disable:next conditional_returns_on_newline
    guard let url = url else { return }
    CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
  }

  fileprivate var url: URL? {
    // swiftlint:disable:next implicit_return
    return BundleToken.bundle.url(forResource: path, withExtension: nil)
  }
}

internal extension FontConvertible.Font {
  convenience init?(font: FontConvertible, size: CGFloat) {
    #if os(iOS) || os(tvOS) || os(watchOS)
    if !UIFont.fontNames(forFamilyName: font.family).contains(font.name) {
      font.register()
    }
    #elseif os(OSX)
    if let url = font.url, CTFontManagerGetScopeForURL(url as CFURL) == .none {
      font.register()
    }
    #endif

    self.init(name: font.name, size: size)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
