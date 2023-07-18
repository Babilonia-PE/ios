// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ColorAsset.Color", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetColorTypeAlias = ColorAsset.Color
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal enum AugmentedReality {
    internal static let housePin = ImageAsset(name: "AugmentedReality/housePin")
    internal static let mapCloseButton = ImageAsset(name: "AugmentedReality/mapCloseButton")
    internal static let mapFullscreenButton = ImageAsset(name: "AugmentedReality/mapFullscreenButton")
    internal static let navigationArrow = ImageAsset(name: "AugmentedReality/navigationArrow")
  }
  internal enum Colors {
    internal static let almostBlack = ColorAsset(name: "Colors/AlmostBlack")
    internal static let antiFlashWhite = ColorAsset(name: "Colors/AntiFlashWhite")
    internal static let aquaSpring = ColorAsset(name: "Colors/AquaSpring")
    internal static let babyBlueEyes = ColorAsset(name: "Colors/BabyBlueEyes")
    internal static let battleshipGray = ColorAsset(name: "Colors/BattleshipGray")
    internal static let biscay = ColorAsset(name: "Colors/Biscay")
    internal static let bleachWhite = ColorAsset(name: "Colors/BleachWhite")
    internal static let blue = ColorAsset(name: "Colors/Blue")
    internal static let bluishGrey = ColorAsset(name: "Colors/BluishGrey")
    internal static let brickRed = ColorAsset(name: "Colors/BrickRed")
    internal static let brightBlue = ColorAsset(name: "Colors/BrightBlue")
    internal static let cloudyBlue = ColorAsset(name: "Colors/CloudyBlue")
    internal static let darkMandy = ColorAsset(name: "Colors/DarkMandy")
    internal static let flamingo = ColorAsset(name: "Colors/Flamingo")
    internal static let grayNurse = ColorAsset(name: "Colors/GrayNurse")
    internal static let gunmetal = ColorAsset(name: "Colors/Gunmetal")
    internal static let hintOfRed = ColorAsset(name: "Colors/HintOfRed")
    internal static let hippieBlue = ColorAsset(name: "Colors/HippieBlue")
    internal static let lightMandy = ColorAsset(name: "Colors/LightMandy")
    internal static let mabel = ColorAsset(name: "Colors/Mabel")
    internal static let mako = ColorAsset(name: "Colors/Mako")
    internal static let mandy = ColorAsset(name: "Colors/Mandy")
    internal static let orange = ColorAsset(name: "Colors/Orange")
    internal static let osloGray = ColorAsset(name: "Colors/OsloGray")
    internal static let pumice = ColorAsset(name: "Colors/Pumice")
    internal static let rosa = ColorAsset(name: "Colors/Rosa")
    internal static let solitude = ColorAsset(name: "Colors/Solitude")
    internal static let trout = ColorAsset(name: "Colors/Trout")
    internal static let veryLightBlueTwo = ColorAsset(name: "Colors/VeryLightBlueTwo")
    internal static let vulcan = ColorAsset(name: "Colors/Vulcan")
    internal static let watermelon = ColorAsset(name: "Colors/Watermelon")
    internal static let whiteLilac = ColorAsset(name: "Colors/WhiteLilac")
    internal static let premiumPlanBackground = ColorAsset(name: "Colors/premiumPlanBackground")
  }
  internal enum Common {
    internal enum Checkbox {
      internal static let checkboxChecked = ImageAsset(name: "Common/Checkbox/checkboxChecked")
      internal static let checkboxUnchecked = ImageAsset(name: "Common/Checkbox/checkboxUnchecked")
    }
    internal static let favoritesIcon = ImageAsset(name: "Common/FavoritesIcon")
    internal static let arrowDownGrey = ImageAsset(name: "Common/arrowDownGrey")
    internal static let backIcon = ImageAsset(name: "Common/backIcon")
    internal static let closeIcon = ImageAsset(name: "Common/closeIcon")
    internal static let dropdownIcon = ImageAsset(name: "Common/dropdownIcon")
    internal static let errorIcon = ImageAsset(name: "Common/errorIcon")
    internal static let inboxSoonIcon = ImageAsset(name: "Common/inboxSoonIcon")
    internal static let minusIcon = ImageAsset(name: "Common/minusIcon")
    internal static let petFriendlyIcon = ImageAsset(name: "Common/petFriendlyIcon")
    internal static let pinIcon = ImageAsset(name: "Common/pinIcon")
    internal static let plusIcon = ImageAsset(name: "Common/plusIcon")
    internal static let sliderIndicator = ImageAsset(name: "Common/sliderIndicator")
    internal static let successIcon = ImageAsset(name: "Common/successIcon")
    internal static let userAvatarPlaceholderSmall = ImageAsset(name: "Common/userAvatarPlaceholderSmall")
  }
  internal enum CreateListing {
    internal static let allFacilitiesIcon = ImageAsset(name: "CreateListing/allFacilitiesIcon")
    internal static let createListingPageAdvanced = ImageAsset(name: "CreateListing/createListingPageAdvanced")
    internal static let createListingPageCommon = ImageAsset(name: "CreateListing/createListingPageCommon")
    internal static let createListingPageDetails = ImageAsset(name: "CreateListing/createListingPageDetails")
    internal static let createListingPageFacilities = ImageAsset(name: "CreateListing/createListingPageFacilities")
    internal static let createListingPagePhotos = ImageAsset(name: "CreateListing/createListingPagePhotos")
    internal static let parkingForVisitsIcon = ImageAsset(name: "CreateListing/parkingForVisitsIcon")
    internal static let parkingIcon = ImageAsset(name: "CreateListing/parkingIcon")
    internal static let uploadPhotoEmptyIcon = ImageAsset(name: "CreateListing/uploadPhotoEmptyIcon")
    internal static let uploadPhotoIcon = ImageAsset(name: "CreateListing/uploadPhotoIcon")
    internal static let warehouseIcon = ImageAsset(name: "CreateListing/warehouseIcon")
  }
  internal enum ListingDetails {
    internal static let calendarIcon = ImageAsset(name: "ListingDetails/calendarIcon")
    internal static let currentLocationIcon = ImageAsset(name: "ListingDetails/currentLocationIcon")
    internal static let floorNumberIcon = ImageAsset(name: "ListingDetails/floorNumberIcon")
    internal static let listingDetailsCameraSmall = ImageAsset(name: "ListingDetails/listingDetailsCameraSmall")
    internal static let mapPinSmall = ImageAsset(name: "ListingDetails/mapPinSmall")
    internal static let mapRoute = ImageAsset(name: "ListingDetails/mapRoute")
    internal static let petFriendlyIconSmall = ImageAsset(name: "ListingDetails/petFriendlyIconSmall")
    internal static let pinApartment = ImageAsset(name: "ListingDetails/pinApartment")
    internal static let pinCommercial = ImageAsset(name: "ListingDetails/pinCommercial")
    internal static let pinHouse = ImageAsset(name: "ListingDetails/pinHouse")
    internal static let pinLand = ImageAsset(name: "ListingDetails/pinLand")
    internal static let pinOffice = ImageAsset(name: "ListingDetails/pinOffice")
    internal static let pinProject = ImageAsset(name: "ListingDetails/pinProject")
    internal static let pinRoom = ImageAsset(name: "ListingDetails/pinRoom")
    internal static let showMoreIcon = ImageAsset(name: "ListingDetails/showMoreIcon")
    internal static let totalFloorsIcon = ImageAsset(name: "ListingDetails/totalFloorsIcon")
  }
  internal enum ListingPreview {
    internal static let arrowDown = ImageAsset(name: "ListingPreview/arrowDown")
    internal static let likeEmpty = ImageAsset(name: "ListingPreview/likeEmpty")
    internal static let likeFilled = ImageAsset(name: "ListingPreview/likeFilled")
    internal static let navigationButton = ImageAsset(name: "ListingPreview/navigationButton")
    internal static let topListingGradient = ImageAsset(name: "ListingPreview/topListingGradient")
  }
  internal enum Main {
    internal static let favoritesTabBarIcon = ImageAsset(name: "Main/favoritesTabBarIcon")
    internal static let listingTabBarIcon = ImageAsset(name: "Main/listingTabBarIcon")
    internal static let notificationsTabBarIcon = ImageAsset(name: "Main/notificationsTabBarIcon")
    internal static let profileTabBarIcon = ImageAsset(name: "Main/profileTabBarIcon")
    internal static let searchTabBarIcon = ImageAsset(name: "Main/searchTabBarIcon")
    internal static let tabBarActiveTopEdge = ImageAsset(name: "Main/tabBarActiveTopEdge")
  }
  internal enum MyListings {
    internal static let favoritesEmpty = ImageAsset(name: "MyListings/favoritesEmpty")
    internal static let myListingsCommercialIcon = ImageAsset(name: "MyListings/myListingsCommercialIcon")
    internal static let myListingsDraft = ImageAsset(name: "MyListings/myListingsDraft")
    internal static let myListingsEmpty = ImageAsset(name: "MyListings/myListingsEmpty")
    internal static let myListingsHouseIcon = ImageAsset(name: "MyListings/myListingsHouseIcon")
    internal static let myListingsLandIcon = ImageAsset(name: "MyListings/myListingsLandIcon")
    internal static let myListingsMore = ImageAsset(name: "MyListings/myListingsMore")
    internal static let myListingsOfficeIcon = ImageAsset(name: "MyListings/myListingsOfficeIcon")
    internal static let myListingsProjectIcon = ImageAsset(name: "MyListings/myListingsProjectIcon")
    internal static let myListingsRoomIcon = ImageAsset(name: "MyListings/myListingsRoomIcon")
    internal static let statContactsIcon = ImageAsset(name: "MyListings/statContactsIcon")
    internal static let statLikesCount = ImageAsset(name: "MyListings/statLikesCount")
    internal static let statViewsIcon = ImageAsset(name: "MyListings/statViewsIcon")
  }
  internal enum Payments {
    internal static let planItemTickIcon = ImageAsset(name: "Payments/planItemTickIcon")
    internal static let planPlusIconWhite = ImageAsset(name: "Payments/planPlusIconWhite")
    internal static let planPremiumIconWhite = ImageAsset(name: "Payments/planPremiumIconWhite")
    internal static let plusIcon = ImageAsset(name: "Payments/plusIcon")
    internal static let plusPlanBackground = ImageAsset(name: "Payments/plusPlanBackground")
    internal static let plusPlanShadow = ImageAsset(name: "Payments/plusPlanShadow")
    internal static let premiumIcon = ImageAsset(name: "Payments/premiumIcon")
    internal static let premiumPlanBackground = ImageAsset(name: "Payments/premiumPlanBackground")
    internal static let premiumPlanShadow = ImageAsset(name: "Payments/premiumPlanShadow")
    internal static let profileCompanyDisabledIcon = ImageAsset(name: "Payments/profileCompanyDisabledIcon")
    internal static let profileCompanyIcon = ImageAsset(name: "Payments/profileCompanyIcon")
    internal static let profileOwnerIcon = ImageAsset(name: "Payments/profileOwnerIcon")
    internal static let profileRealtorDisabledIcon = ImageAsset(name: "Payments/profileRealtorDisabledIcon")
    internal static let profileRealtorIcon = ImageAsset(name: "Payments/profileRealtorIcon")
    internal static let radioButtonDisabled = ImageAsset(name: "Payments/radioButtonDisabled")
    internal static let radioButtonEnabled = ImageAsset(name: "Payments/radioButtonEnabled")
    internal static let standartPlanBackground = ImageAsset(name: "Payments/standartPlanBackground")
    internal static let standartPlanShadow = ImageAsset(name: "Payments/standartPlanShadow")
  }
  internal enum Profile {
    internal static let accessoryArrow = ImageAsset(name: "Profile/accessoryArrow")
    internal static let edit = ImageAsset(name: "Profile/edit")
    internal static let radiobtn = ImageAsset(name: "Profile/radiobtn")
    internal static let userPlaceholder = ImageAsset(name: "Profile/userPlaceholder")
  }
  internal enum Search {
    internal enum Map {
      internal static let apartmentPinIcon = ImageAsset(name: "Search/Map/apartmentPinIcon")
      internal static let apartmentViewedPinIcon = ImageAsset(name: "Search/Map/apartmentViewedPinIcon")
      internal static let commercialPinIcon = ImageAsset(name: "Search/Map/commercialPinIcon")
      internal static let commercialViewedPinIcon = ImageAsset(name: "Search/Map/commercialViewedPinIcon")
      internal static let housePinIcon = ImageAsset(name: "Search/Map/housePinIcon")
      internal static let houseViewedPinIcon = ImageAsset(name: "Search/Map/houseViewedPinIcon")
      internal static let landPinIcon = ImageAsset(name: "Search/Map/landPinIcon")
      internal static let landViewedPinIcon = ImageAsset(name: "Search/Map/landViewedPinIcon")
      internal static let officePinIcon = ImageAsset(name: "Search/Map/officePinIcon")
      internal static let officeViewedPinIcon = ImageAsset(name: "Search/Map/officeViewedPinIcon")
      internal static let popupARIcon = ImageAsset(name: "Search/Map/popupARIcon")
      internal static let popupLocationIcon = ImageAsset(name: "Search/Map/popupLocationIcon")
      internal static let projectPinIcon = ImageAsset(name: "Search/Map/projectPinIcon")
      internal static let projectViewedPinIcon = ImageAsset(name: "Search/Map/projectViewedPinIcon")
      internal static let roomPinIcon = ImageAsset(name: "Search/Map/roomPinIcon")
      internal static let roomViewedPinIcon = ImageAsset(name: "Search/Map/roomViewedPinIcon")
      internal static let searchMapPin = ImageAsset(name: "Search/Map/searchMapPin")
    }
    internal static let arModeIcon = ImageAsset(name: "Search/arModeIcon")
    internal static let currentLocationIcon = ImageAsset(name: "Search/currentLocationIcon")
    internal static let filterIcon = ImageAsset(name: "Search/filterIcon")
    internal static let filterIconSelected = ImageAsset(name: "Search/filterIconSelected")
    internal static let listModeIcon = ImageAsset(name: "Search/listModeIcon")
    internal static let logoIcon = ImageAsset(name: "Search/logoIcon")
    internal static let mapModeIcon = ImageAsset(name: "Search/mapModeIcon")
    internal static let myLocationIcon = ImageAsset(name: "Search/myLocationIcon")
    internal static let searchListingsEmpty = ImageAsset(name: "Search/searchListingsEmpty")
  }
  internal enum Splash {
    internal static let logo = ImageAsset(name: "Splash/logo")
  }
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal final class ColorAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  internal private(set) lazy var color: Color = {
    guard let color = Color(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }()

  fileprivate init(name: String) {
    self.name = name
  }
}

internal extension ColorAsset.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  convenience init?(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Image = UIImage
  #endif

  internal var image: Image {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let name = NSImage.Name(self.name)
    let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
}

internal extension ImageAsset.Image {
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init?(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
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
