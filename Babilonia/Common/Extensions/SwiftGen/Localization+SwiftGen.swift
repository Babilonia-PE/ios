// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {

  internal enum Ar {
    internal enum DestinationReached {
      /// Llegaste a tu destino.
      internal static let title = L10n.tr("Localizable", "ar.destination_reached.title")
    }
    internal enum Main {
      /// Propiedades en venta
      internal static let subtitle = L10n.tr("Localizable", "ar.main.subtitle")
      /// Vista AR
      internal static let title = L10n.tr("Localizable", "ar.main.title")
    }
    internal enum MapView {
      /// Ver mapa
      internal static let title = L10n.tr("Localizable", "ar.mapView.title")
    }
    internal enum MetersCounter {
      internal enum Many {
        /// metros
        internal static let title = L10n.tr("Localizable", "ar.meters_counter.many.title")
      }
      internal enum Single {
        /// metro
        internal static let title = L10n.tr("Localizable", "ar.meters_counter.single.title")
      }
    }
  }

  internal enum Buttons {
    internal enum Cancel {
      /// Cancelar
      internal static let title = L10n.tr("Localizable", "buttons.cancel.title")
    }
    internal enum Done {
      /// Listo
      internal static let title = L10n.tr("Localizable", "buttons.done.title")
    }
    internal enum OkButton {
      /// OK
      internal static let title = L10n.tr("Localizable", "buttons.ok_button.title")
    }
    internal enum Save {
      /// Guardar
      internal static let title = L10n.tr("Localizable", "buttons.save.title")
    }
    internal enum Settings {
      /// Configuración
      internal static let title = L10n.tr("Localizable", "buttons.settings.title")
    }
    internal enum Login {
    /// Login
    internal static let title = L10n.tr("Localizable", "buttons.login.title")
    }
  }

  internal enum Common {
    internal enum For {
      /// en %@
      internal static func text(_ p1: Any) -> String {
        return L10n.tr("Localizable", "common.for.text", String(describing: p1))
      }
    }
    internal static let share = L10n.tr("Localizable", "common.share")
    internal static let all = L10n.tr("Localizable", "common.all")
  }

  internal enum CreateListing {
    /// Crear un nuevo aviso
    internal static let title = L10n.tr("Localizable", "create_listing.title")
    internal enum Common {
      internal enum Address {
        /// Ingrese una dirección
        internal static let placeholder = L10n.tr("Localizable", "create_listing.common.address.placeholder")
        /// Dirección
        internal static let title = L10n.tr("Localizable", "create_listing.common.address.title")
        internal enum UnknowLocation {
          /// Ubicación indeterminada
          internal static let text = L10n.tr("Localizable", "create_listing.common.address.unknow_location.text")
        }
      }
      internal enum Area {
        /// Área del inmueble
        internal static let placeholder = L10n.tr("Localizable", "create_listing.common.area.placeholder")
        /// Área, m²
        internal static let title = L10n.tr("Localizable", "create_listing.common.area.title")
      }
      internal enum Country {
        /// País
        internal static let title = L10n.tr("Localizable", "create_listing.common.country.title")
      }
      internal enum Department {
        /// Departamento
        internal static let title = L10n.tr("Localizable", "create_listing.common.department.title")
      }
      internal enum Description {
        /// La descripción no debe estar vacía
        internal static let emptyErrorText = L10n.tr("Localizable", "create_listing.common.description.empty_error_text")
        /// La descripción no debe superar los %d caracteres
        internal static func largeErrorText(_ p1: Int) -> String {
          return L10n.tr("Localizable", "create_listing.common.description.large_error_text", p1)
        }
        /// Sobre su inmueble
        internal static let placeholder = L10n.tr("Localizable", "create_listing.common.description.placeholder")
        /// Descripción (%d/%d)
        internal static func title(_ p1: Int, _ p2: Int) -> String {
          return L10n.tr("Localizable", "create_listing.common.description.title", p1, p2)
        }
        internal enum Edit {
          /// Descripción
          internal static let title = L10n.tr("Localizable", "create_listing.common.description.edit.title")
        }
      }
      internal enum District {
        /// Distrito
        internal static let title = L10n.tr("Localizable", "create_listing.common.district.title")
      }
      internal enum ListingType {
        /// TIPO DE OPERACIÓN
        internal static let title = L10n.tr("Localizable", "create_listing.common.listing_type.title")
        internal enum Rent {
          /// Alquiler
          internal static let title = L10n.tr("Localizable", "create_listing.common.listing_type.rent.title")
        }
        internal enum Sale {
          /// Venta
          internal static let title = L10n.tr("Localizable", "create_listing.common.listing_type.sale.title")
        }
      }
      internal enum PropertyType {
        /// Tipo de inmueble
        internal static let title = L10n.tr("Localizable", "create_listing.common.property_type.title")
        internal enum Apartment {
          /// Departamento
          internal static let title = L10n.tr("Localizable", "create_listing.common.property_type.apartment.title")
        }
        internal enum Commercial {
          /// Local comercial
          internal static let title = L10n.tr("Localizable", "create_listing.common.property_type.commercial.title")
        }
        internal enum House {
          /// Casa
          internal static let title = L10n.tr("Localizable", "create_listing.common.property_type.house.title")
        }
        internal enum Land {
          /// Terreno
          internal static let title = L10n.tr("Localizable", "create_listing.common.property_type.land.title")
        }
        internal enum Office {
          /// Oficina
          internal static let title = L10n.tr("Localizable", "create_listing.common.property_type.office.title")
        }
        internal enum Project {
          /// Proyecto
          internal static let title = L10n.tr("Localizable", "create_listing.common.property_type.project.title")
        }
        internal enum Room {
          /// Cuarto
          internal static let title = L10n.tr("Localizable", "create_listing.common.property_type.room.title")
        }
          internal enum LocalIndustrial {
            /// Local Industrial
            internal static let title = L10n.tr("Localizable", "create_listing.common.property_type.local_industrial.title")
          }
          internal enum LandAgricultural {
            /// Terreno Agrícola;
            internal static let title = L10n.tr("Localizable", "create_listing.common.property_type.land_agricultural.title")
          }
          internal enum LandIndustrial {
            /// Terreno Industrial
            internal static let title = L10n.tr("Localizable", "create_listing.common.property_type.land_industrial.title")
          }
          internal enum LandCommercial {
            /// Terreno Comercial
            internal static let title = L10n.tr("Localizable", "create_listing.common.property_type.land_commercial.title")
          }
          internal enum Cottage {
            /// Casa de Campo
            internal static let title = L10n.tr("Localizable", "create_listing.common.property_type.cottage.title")
          }
          internal enum BeachHouse {
            /// Casa de Playa
            internal static let title = L10n.tr("Localizable", "create_listing.common.property_type.beach_house.title")
          }
          internal enum Building {
            /// Edificio
            internal static let title = L10n.tr("Localizable", "create_listing.common.property_type.building.title")
          }
          internal enum Hotel {
            /// Hotel
            internal static let title = L10n.tr("Localizable", "create_listing.common.property_type.hotel.title")
          }
          internal enum Deposit {
            /// Depósito
            internal static let title = L10n.tr("Localizable", "create_listing.common.property_type.deposit.title")
          }
          internal enum Parking {
            /// Estacionamiento
            internal static let title = L10n.tr("Localizable", "create_listing.common.property_type.parking.title")
          }
          internal enum Airs {
            /// Aires
            internal static let title = L10n.tr("Localizable", "create_listing.common.property_type.airs.title")
          }
      }
      internal enum Province {
        /// Provincia
        internal static let title = L10n.tr("Localizable", "create_listing.common.province.title")
      }
    }
    internal enum Continue {
      /// CONTINUAR (%d/%d)
      internal static func title(_ p1: Int, _ p2: Int) -> String {
        return L10n.tr("Localizable", "create_listing.continue.title", p1, p2)
      }
    }
    internal enum Created {
      /// Aviso actualizado con éxito
      internal static let alert = L10n.tr("Localizable", "create_listing.created.alert")
    }
    internal enum Details {
      /// Estacionamiento para visitas
      internal static let parkingForVisitors = L10n.tr("Localizable", "create_listing.details.parking_for_visitors")
      internal enum Bathrooms {
        /// Baños
        internal static let title = L10n.tr("Localizable", "create_listing.details.bathrooms.title")
        internal enum Title {
          /// Baño
          internal static let singular = L10n.tr("Localizable", "create_listing.details.bathrooms.title.singular")
        }
      }
      internal enum Bedrooms {
        /// Dormitorios
        internal static let title = L10n.tr("Localizable", "create_listing.details.bedrooms.title")
        internal enum Title {
          /// Dormitorio
          internal static let singular = L10n.tr("Localizable", "create_listing.details.bedrooms.title.singular")
        }
      }
      internal enum EmptyAdvanced {
        /// %@ no tiene características adicionales, así que saltémonos este paso
        internal static func title(_ p1: Any) -> String {
          return L10n.tr("Localizable", "create_listing.details.empty_advanced.title", String(describing: p1))
        }
      }
      internal enum EmptyDetails {
        /// %@ no tiene detalles generales, así que saltémonos este paso
        internal static func title(_ p1: Any) -> String {
          return L10n.tr("Localizable", "create_listing.details.empty_details.title", String(describing: p1))
        }
      }
      internal enum EmptyFacilities {
        /// %@ no tiene comodidades, así que saltémonos este paso
        internal static func title(_ p1: Any) -> String {
          return L10n.tr("Localizable", "create_listing.details.empty_facilities.title", String(describing: p1))
        }
      }
      internal enum ParkingSlots {
        /// Estacionamientos
        internal static let title = L10n.tr("Localizable", "create_listing.details.parking_slots.title")
      }
      internal enum PetFriendly {
        /// Pet-friendly
        internal static let title = L10n.tr("Localizable", "create_listing.details.pet_friendly.title")
      }
      internal enum Price {
        internal enum Rent {
          /// Precio por mes, USD
          internal static let title = L10n.tr("Localizable", "create_listing.details.price.rent.title")
        }
        internal enum Sale {
          /// Precio, USD
          internal static let title = L10n.tr("Localizable", "create_listing.details.price.sale.title")
        }
      }
      internal enum YearOfConstruction {
        /// Año de construcción
        internal static let title = L10n.tr("Localizable", "create_listing.details.year_of_construction.title")
      }
    }
    internal enum Facilities {
      /// COMODIDADES
      internal static let title = L10n.tr("Localizable", "create_listing.facilities.title")
    }
    internal enum Finish {
      internal enum Button {
        /// Salir
        internal static let title = L10n.tr("Localizable", "create_listing.finish.button.title")
      }
      internal enum EditPopup {
        ///  Puede salir, pero se perderá el progreso de la edición
        internal static let text = L10n.tr("Localizable", "create_listing.finish.edit_popup.text")
        /// ¿Terminaste de editar?
        internal static let title = L10n.tr("Localizable", "create_listing.finish.edit_popup.title")
        internal enum Continue {
          /// Continuar editando
          internal static let title = L10n.tr("Localizable", "create_listing.finish.edit_popup.continue.title")
        }
      }
      internal enum Popup {
        /// Puedes salir de la creación y guardaremos tu progreso para que puedas continuar más tarde.
        internal static let text = L10n.tr("Localizable", "create_listing.finish.popup.text")
        /// ¿Terminaste tu aviso?
        internal static let title = L10n.tr("Localizable", "create_listing.finish.popup.title")
        internal enum Continue {
          /// Continuar creando
          internal static let title = L10n.tr("Localizable", "create_listing.finish.popup.continue.title")
        }
        internal enum DontSaveAndExit {
          /// No guardar y salir
          internal static let title = L10n.tr("Localizable", "create_listing.finish.popup.dont_save_and_exit.title")
        }
        internal enum SaveAndExit {
          /// Guardar y salir
          internal static let title = L10n.tr("Localizable", "create_listing.finish.popup.save_and_exit.title")
        }
      }
    }
    internal enum ListingPreview {
      /// Ocultar aviso
      internal static let subtitle = L10n.tr("Localizable", "create_listing.listing_preview.subtitle")
      /// Vista previa
      internal static let title = L10n.tr("Localizable", "create_listing.listing_preview.title")
      internal enum Publish {
        /// PUBLICAR
        internal static let title = L10n.tr("Localizable", "create_listing.listing_preview.publish.title")
      }
    }
    internal enum Photos {
      internal enum EmptyState {
        /// Elija las fotos que mejor representen su propiedad
        internal static let text = L10n.tr("Localizable", "create_listing.photos.empty_state.text")
        internal enum Button {
          /// CARGAR FOTOS
          internal static let title = L10n.tr("Localizable", "create_listing.photos.empty_state.button.title")
        }
      }
      internal enum Options {
        internal enum Delete {
          /// Eliminar foto
          internal static let title = L10n.tr("Localizable", "create_listing.photos.options.delete.title")
        }
        internal enum SetAsMain {
          /// Establecer como foto principal
          internal static let title = L10n.tr("Localizable", "create_listing.photos.options.set_as_main.title")
        }
      }
      internal enum PhotoCell {
        internal enum MainImage {
          /// Foto principal
          internal static let text = L10n.tr("Localizable", "create_listing.photos.photo_cell.main_image.text")
        }
      }
      internal enum UploadView {
        /// Cargar mas fotos (%d/%d)
        internal static func title(_ p1: Int, _ p2: Int) -> String {
          return L10n.tr("Localizable", "create_listing.photos.upload_view.title", p1, p2)
        }
      }
    }
    internal enum Preview {
      /// VISTA PREVIA
      internal static let title = L10n.tr("Localizable", "create_listing.preview.title")
    }
    internal enum Steps {
      internal enum Advanced {
        /// Adicionales
        internal static let title = L10n.tr("Localizable", "create_listing.steps.advanced.title")
      }
      internal enum Common {
        /// General
        internal static let title = L10n.tr("Localizable", "create_listing.steps.common.title")
      }
      internal enum Details {
        /// Características
        internal static let title = L10n.tr("Localizable", "create_listing.steps.details.title")
      }
      internal enum Facilities {
        /// Comodidades
        internal static let title = L10n.tr("Localizable", "create_listing.steps.facilities.title")
      }
      internal enum General {
        /// General
        internal static let title = L10n.tr("Localizable", "create_listing.steps.general.title")
      }
      internal enum Photos {
        /// Fotos
        internal static let title = L10n.tr("Localizable", "create_listing.steps.photos.title")
      }
    }
  }

  internal enum Currency {
    internal enum Sol {
      /// S/
      internal static let code = L10n.tr("Localizable", "currency.sol.code")
      /// S/
      internal static let symbol = L10n.tr("Localizable", "currency.sol.symbol")
      /// Nuevo sol (PEN)
      internal static let title = L10n.tr("Localizable", "currency.sol.title")
    }
    internal enum Usd {
      /// USD
      internal static let code = L10n.tr("Localizable", "currency.usd.code")
      /// $
      internal static let symbol = L10n.tr("Localizable", "currency.usd.symbol")
      /// Dólar estadounidense (USD)
      internal static let title = L10n.tr("Localizable", "currency.usd.title")
    }
  }

  internal enum EditListing {
    /// Editar aviso
    internal static let title = L10n.tr("Localizable", "edit_listing.title")
  }

  internal enum EditProfile {
    /// La imagen debe estar en formato .png, .jpg o .jpeg
    internal static let avatarFormats = L10n.tr("Localizable", "edit_profile.avatar_formats")
    /// Editar Perfil
    internal static let title = L10n.tr("Localizable", "edit_profile.title")
    internal enum Buttons {
      internal enum ChangePhoto {
        /// CAMBIAR FOTO
        internal static let title = L10n.tr("Localizable", "edit_profile.buttons.change_photo.title")
      }
      internal enum Save {
        /// GUARDAR
        internal static let title = L10n.tr("Localizable", "edit_profile.buttons.save.title")
      }
    }
    internal enum ChangeEmail {
      /// Cambiar correo electrónico
      internal static let title = L10n.tr("Localizable", "edit_profile.change_email.title")
    }
      internal enum ChangePhoneNumber {
        /// Cambiar correo electrónico
        internal static let title = L10n.tr("Localizable", "edit_profile.change_phone_number.title")
      }
    internal enum ExitAlert {
      /// Usted tiene cambios sin guardar. Si sale, se perderán.
      internal static let message = L10n.tr("Localizable", "edit_profile.exit_alert.message")
      /// ¿Desea guardar los cambios?
      internal static let title = L10n.tr("Localizable", "edit_profile.exit_alert.title")
    }
    internal enum FirstName {
      /// Nombre
      internal static let title = L10n.tr("Localizable", "edit_profile.first_name.title")
    }
    internal enum LastName {
      /// Apellido
      internal static let title = L10n.tr("Localizable", "edit_profile.last_name.title")
    }
  internal enum FullName {
    /// Apellido
    internal static let title = L10n.tr("Localizable", "edit_profile.full_name.title")
  }
    internal enum UpdateAvatar {
      internal enum Popup {
        internal enum Success {
          /// Foto cargada correctamente
          internal static let text = L10n.tr("Localizable", "edit_profile.update_avatar.popup.success.text")
        }
      }
    }
    internal enum UpdateEmail {
      internal enum Popup {
        internal enum Success {
          /// Correo actualizado con éxito
          internal static let text = L10n.tr("Localizable", "edit_profile.update_email.popup.success.text")
        }
      }
    }
    internal enum UpdateUser {
      internal enum Popup {
        internal enum Success {
          /// Perfil actualizado con éxito
          internal static let text = L10n.tr("Localizable", "edit_profile.update_user.popup.success.text")
        }
      }
    }
  }

  internal enum Errors {
    /// ¡Lo sentimos! Algo salió mal...
    internal static let somethingWentWrong = L10n.tr("Localizable", "errors.something_went_wrong")
    internal static let actionMustBeDoneFromWeb = L10n.tr("Localizable", "errors.action_must_be_done_from_web")
    internal enum Network {
      /// Request was cancelled by the system.
      internal static let canceled = L10n.tr("Localizable", "errors.network.canceled")
      /// No se pueden cargar los datos. Por favor compruebe su conexión a internet y vuelva a intentarlo.
      internal static let connection = L10n.tr("Localizable", "errors.network.connection")
      /// Error interno del servidor. Por favor inténtelo de nuevo más tarde.
      internal static let internalServer = L10n.tr("Localizable", "errors.network.internalServer")
      /// Apareció un error de red no autorizado.
      internal static let unauthorized = L10n.tr("Localizable", "errors.network.unauthorized")
      /// Apareció un error de red no definido. Por favor inténtelo más tarde.
      internal static let undefined = L10n.tr("Localizable", "errors.network.undefined")
      /// Apareció un error de encabezado de red insatisfecho.
      internal static let unsatisfiedHeader = L10n.tr("Localizable", "errors.network.unsatisfied_header")
    }
    internal enum Payment {
      /// Pago rechazado. Por favor verifique los detalles de su tarjeta o comuníquese con su banco para mayor asistencia.
      internal static let declined = L10n.tr("Localizable", "errors.payment.declined")
    }
    internal enum SomethingWentWrong {
      /// Algo salió mal. Por favor vuelva a intentarlo o comuníquese con nosotros si el problema persiste.
      internal static let long = L10n.tr("Localizable", "errors.something_went_wrong.long")
    }
  }

  internal enum FavoritesListings {
    /// Favoritos
    internal static let title = L10n.tr("Localizable", "favorites_listings.title")
    internal enum Empty {
      /// Tu lista de favoritos está vacía
      internal static let title = L10n.tr("Localizable", "favorites_listings.empty.title")
      internal enum Description {
        /// Para agregar inmuebles a tu lista, presiona el icono 
        internal static let first = L10n.tr("Localizable", "favorites_listings.empty.description.first")
        ///  que se ecuentra en los avisos. ¡Ánimo! Empieza a guardar los inmuebles que más te gustan y no los pierdas de vista
        internal static let second = L10n.tr("Localizable", "favorites_listings.empty.description.second")
      }
    }
  }

  internal enum Filters {
    /// Todas las comodidades
    internal static let allFacilities = L10n.tr("Localizable", "filters.all_facilities")
    /// APLICAR FILTROS
    internal static let applyFilters = L10n.tr("Localizable", "filters.apply_filters")
    /// Área de construcción, m²
    internal static let builtArea = L10n.tr("Localizable", "filters.built_area")
    /// Área techada, m²
    internal static let coveredArea = L10n.tr("Localizable", "filters.covered_area")
    /// Piso de la unidad
    internal static let floorNumber = L10n.tr("Localizable", "filters.floor_number")
    /// En alquiler
    internal static let forRent = L10n.tr("Localizable", "filters.for_rent")
    /// En venta
    internal static let forSale = L10n.tr("Localizable", "filters.for_sale")
    /// %i inmuebles encontrados
    internal static func listingsFound(_ p1: Int) -> String {
      return L10n.tr("Localizable", "filters.listings_found", p1)
    }
    /// Estacionamiento
    internal static let parking = L10n.tr("Localizable", "filters.parking")
    /// %i estac
    internal static func parkingSlots(_ p1: Int) -> String {
      return L10n.tr("Localizable", "filters.parking_slots", p1)
    }
    /// Rango de precio:
    internal static let priceRange = L10n.tr("Localizable", "filters.price_range")
    /// Comodidades
    internal static let propertyFacilities = L10n.tr("Localizable", "filters.property_facilities")
    /// Restablecer
    internal static let reset = L10n.tr("Localizable", "filters.reset")
    /// Filtros
    internal static let title = L10n.tr("Localizable", "filters.title")
    /// Área total, m²
    internal static let totalArea = L10n.tr("Localizable", "filters.total_area")
    /// Pisos totales
    internal static let totalFloors = L10n.tr("Localizable", "filters.total_floors")
    /// Almacén
    internal static let warehouse = L10n.tr("Localizable", "filters.warehouse")
    internal enum Applied {
      /// %i - %i m²
      internal static func areaRange(_ p1: Int, _ p2: Int) -> String {
        return L10n.tr("Localizable", "filters.applied.area_range", p1, p2)
      }
      /// pisos
      internal static let floors = L10n.tr("Localizable", "filters.applied.floors")
      internal enum BuiltArea {
        /// Construcción: 
        internal static let type = L10n.tr("Localizable", "filters.applied.builtArea.type")
      }
      internal enum CoveredArea {
        /// Techada: 
        internal static let type = L10n.tr("Localizable", "filters.applied.coveredArea.type")
      }
      internal enum Floors {
        /// piso
        internal static let singular = L10n.tr("Localizable", "filters.applied.floors.singular")
      }
      internal enum TotalArea {
        /// Total: 
        internal static let type = L10n.tr("Localizable", "filters.applied.totalArea.type")
      }
    }
    internal enum ParkingSlots {
      /// %i estac
      internal static func singular(_ p1: Int) -> String {
        return L10n.tr("Localizable", "filters.parking_slots.singular", p1)
      }
    }
    internal enum PropertyType {
      /// Todos
      internal static let any = L10n.tr("Localizable", "filters.property_type.any")
    }
    internal enum Range {
      /// Desde
      internal static let from = L10n.tr("Localizable", "filters.range.from")
      /// Máx
      internal static let max = L10n.tr("Localizable", "filters.range.max")
      /// Mín
      internal static let min = L10n.tr("Localizable", "filters.range.min")
      /// Hasta
      internal static let to = L10n.tr("Localizable", "filters.range.to")
    }
  }

  internal enum Guest {
    internal enum Message {
      /// Inicia sesión o regístrate para poder acceder a todas nuestras funciones\n\n• Ponte en contacto con los anunciantes\n• Agrega inmuebles a tus favoritos\n• Publica y maneja tus inmuebles
      internal static let title = L10n.tr("Localizable", "guest.message.title")
    }
    internal enum Welcome {
      /// Ingresa a Babilonia
      internal static let title = L10n.tr("Localizable", "guest.welcome.title")
    }
  }

  internal enum Hud {
    internal enum Alert {
      internal enum Error {
        /// Error
        internal static let title = L10n.tr("Localizable", "hud.alert.error.title")
      }
      internal enum Info {
        /// Información
        internal static let title = L10n.tr("Localizable", "hud.alert.info.title")
      }
      internal enum Success {
        /// Éxito
        internal static let title = L10n.tr("Localizable", "hud.alert.success.title")
      }
        internal enum Loading {
          /// Cargando
          internal static let title = L10n.tr("Localizable", "hud.alert.loading.title")
        }
    }
  }

  internal enum ImagePicker {
    internal enum Camera {
      /// Cámara
      internal static let title = L10n.tr("Localizable", "image_picker.camera.title")
    }
    internal enum Gallery {
      /// Cargar desde la galería
      internal static let title = L10n.tr("Localizable", "image_picker.gallery.title")
    }
  }

  internal enum Inbox {
    /// Próximamente...
    internal static let commingSoon = L10n.tr("Localizable", "inbox.comming_soon")
  }

  internal enum Listing {
    internal enum List {
      /// Ordenar por:
      internal static let sortBy = L10n.tr("Localizable", "listing.list.sort_by")
      /// Ordenando
      internal static let sorting = L10n.tr("Localizable", "listing.list.sorting")
    }
    internal enum SortOption {
      /// Área: Más amplios
      internal static let areaHighestToLowest = L10n.tr("Localizable", "listing.sort_option.area_highest_to_lowest")
      /// Área: Más pequeños
      internal static let areaLowestToHighest = L10n.tr("Localizable", "listing.sort_option.area_lowest_to_highest")
      /// Más cercanos
      internal static let closestToFarthest = L10n.tr("Localizable", "listing.sort_option.closest_to_farthest")
      /// Más lejanos
      internal static let farthestToClosest = L10n.tr("Localizable", "listing.sort_option.farthest_to_closest")
      /// Precio por m2: Alto a bajo
      internal static let m2PriceHighestToLowest = L10n.tr("Localizable", "listing.sort_option.m2_price_highest_to_lowest")
      /// Precio por m2: Bajo a alto
      internal static let m2PriceLowestToHighest = L10n.tr("Localizable", "listing.sort_option.m2_price_lowest_to_highest")
      /// Relevancia
      internal static let mostRelevant = L10n.tr("Localizable", "listing.sort_option.most_relevant")
      /// Más nuevos
      internal static let newestToOldest = L10n.tr("Localizable", "listing.sort_option.newest_to_oldest")
      /// Más antiguos
      internal static let oldestToNewest = L10n.tr("Localizable", "listing.sort_option.oldest_to_newest")
      /// Precio: Alto a bajo
      internal static let priceHighToLow = L10n.tr("Localizable", "listing.sort_option.price_high_to_low")
      /// Precio: Bajo a alto
      internal static let priceLowToHigh = L10n.tr("Localizable", "listing.sort_option.price_low_to_high")
    }
  }

  internal enum ListingDetails {
    internal enum About {
      /// Sobre este inmueble
      internal static let title = L10n.tr("Localizable", "listing_details.about.title")
      internal enum ShowMore {
        /// Mostrar más
        internal static let title = L10n.tr("Localizable", "listing_details.about.show_more.title")
      }
      internal enum Year {
        /// Construido en %@
        internal static func text(_ p1: Any) -> String {
          return L10n.tr("Localizable", "listing_details.about.year.text", String(describing: p1))
        }
      }
    }
    internal enum Action {
      /// Más
      internal static let more = L10n.tr("Localizable", "listing_details.action.more")
      /// Reportar
      internal static let report = L10n.tr("Localizable", "listing_details.action.report")
    }
    internal enum Advanced {
      /// Características adicionales
      internal static let title = L10n.tr("Localizable", "listing_details.advanced.title")
    }
    internal enum Bathrooms {
      /// %d baños
      internal static func text(_ p1: Int) -> String {
        return L10n.tr("Localizable", "listing_details.bathrooms.text", p1)
      }
      internal enum Text {
        /// %d baño
        internal static func singular(_ p1: Int) -> String {
          return L10n.tr("Localizable", "listing_details.bathrooms.text.singular", p1)
        }
      }
    }
    internal enum Bedrooms {
      /// %d dormitorios
      internal static func text(_ p1: Int) -> String {
        return L10n.tr("Localizable", "listing_details.bedrooms.text", p1)
      }
      internal enum Text {
        /// %d dormitorio
        internal static func singular(_ p1: Int) -> String {
          return L10n.tr("Localizable", "listing_details.bedrooms.text.singular", p1)
        }
      }
    }
    internal enum BuiltArea {
      /// Área de construcción:
      internal static let text = L10n.tr("Localizable", "listing_details.built_area.text")
    }
    internal enum Call {
      /// Llamar
      internal static let actionsTitle = L10n.tr("Localizable", "listing_details.call.actions_title")
    }
    internal enum ContactButton {
      /// Esta llamada puede incurrir costos adicionales
      internal static let description = L10n.tr("Localizable", "listing_details.contact_button.description")
      /// Llamar
      internal static let title = L10n.tr("Localizable", "listing_details.contact_button.title")
    }
    internal enum CoveredArea {
      /// Área techada:
      internal static let text = L10n.tr("Localizable", "listing_details.covered_area.text")
    }
    internal enum Facilities {
      /// Comodidades
      internal static let title = L10n.tr("Localizable", "listing_details.facilities.title")
    }
    internal enum FloorNumber {
      /// Piso #%i
      internal static func text(_ p1: Int) -> String {
        return L10n.tr("Localizable", "listing_details.floor_number.text", p1)
      }
    }
    internal enum Map {
      internal enum Actions {
        /// Usar Apple Maps 
        internal static let appleMaps = L10n.tr("Localizable", "listing_details.map.actions.apple_maps")
        /// Usar Google Map
        internal static let googleMaps = L10n.tr("Localizable", "listing_details.map.actions.google_maps")
        /// Elija el proveedor de mapas
        internal static let title = L10n.tr("Localizable", "listing_details.map.actions.title")
        /// Usar Waze
        internal static let waze = L10n.tr("Localizable", "listing_details.map.actions.waze")
      }
    }
    internal enum ParkingForVisitors {
      /// estac para visitas
      internal static let text = L10n.tr("Localizable", "listing_details.parking_for_visitors.text")
    }
    internal enum ParkingSlots {
      /// %d estacionamientos
      internal static func text(_ p1: Int) -> String {
        return L10n.tr("Localizable", "listing_details.parking_slots.text", p1)
      }
      internal enum Text {
        /// %d estacionamiento
        internal static func singular(_ p1: Int) -> String {
          return L10n.tr("Localizable", "listing_details.parking_slots.text.singular", p1)
        }
      }
    }
    internal enum PetFriendly {
      /// Pet-friendly
      internal static let text = L10n.tr("Localizable", "listing_details.pet_friendly.text")
    }
    internal enum PricePerMonth {
      /// al mes
      internal static let text = L10n.tr("Localizable", "listing_details.price_per_month.text")
    }
    internal enum PricePerSquareMeter {
      /// %@%d/m²
      internal static func text(_ p1: Any, _ p2: Int) -> String {
        return L10n.tr("Localizable", "listing_details.price_per_square_meter.text", String(describing: p1), p2)
      }
    }
    internal enum Status {
      /// Aviso expirado
      internal static let expired = L10n.tr("Localizable", "listing_details.status.expired")
      /// Aviso no publicado
      internal static let notPublished = L10n.tr("Localizable", "listing_details.status.not_published")
      /// Aviso publicado
      internal static let published = L10n.tr("Localizable", "listing_details.status.published")
      /// Aviso despublicado
      internal static let unpublished = L10n.tr("Localizable", "listing_details.status.unpublished")
    }
    internal enum TotalArea {
      /// Área total:
      internal static let text = L10n.tr("Localizable", "listing_details.total_area.text")
    }
    internal enum TotalFloorsCount {
      /// %i pisos totales
      internal static func text(_ p1: Int) -> String {
        return L10n.tr("Localizable", "listing_details.total_floors_count.text", p1)
      }
    }
  }

  internal enum ListingPreview {
    internal enum Navigate {
      /// NAVEGAR
      internal static let title = L10n.tr("Localizable", "listing_preview.navigate.title")
    }
    internal enum ShowDetails {
      /// VER INMUEBLE
      internal static let title = L10n.tr("Localizable", "listing_preview.show_details.title")
    }
  }

  internal enum ListingSearch {
    /// Inmuebles Top
    internal static let topListingsTitle = L10n.tr("Localizable", "listing_search.top_listings_title")
    internal enum ArPopup {
      /// ¿Te gusta la zona en donde estás? Escanéala con la vista AR y descubre que inmuebles están en venta o alquiler. Haz clic en navegar y te llevaremos al inmueble por la ruta más corta.
      internal static let text = L10n.tr("Localizable", "listing_search.ar_popup.text")
      /// Busca propiedades\n con Realidad Aumentada
      internal static let title = L10n.tr("Localizable", "listing_search.ar_popup.title")
    }
    internal enum EmptyResult {
      /// Intente cambiar el criterio de búsqueda.
      internal static let text = L10n.tr("Localizable", "listing_search.empty_result.text")
      /// ¡Lo sentimos! No encontramos inmuebles como el que busca...
      internal static let title = L10n.tr("Localizable", "listing_search.empty_result.title")
    }
    internal enum LocationPopup {
      /// Para mostrarte inmuebles cerca a ti. Además, podrás ver tu ubicación en la vista de mapa.
      internal static let text = L10n.tr("Localizable", "listing_search.location_popup.text")
      /// Porque preguntamos por tu ubicación
      internal static let title = L10n.tr("Localizable", "listing_search.location_popup.title")
      internal enum Cancel {
        /// Ahora no
        internal static let title = L10n.tr("Localizable", "listing_search.location_popup.cancel.title")
      }
      internal enum Done {
        /// ENTENDIDO
        internal static let title = L10n.tr("Localizable", "listing_search.location_popup.done.title")
      }
    }
    internal enum SearchBar {
      /// Dirección, distrito o ciudad
      internal static let placeholder = L10n.tr("Localizable", "listing_search.search_bar.placeholder")
    }
  }

  internal enum MyListings {
    /// Le quedan %i días
    internal static func daysLeft(_ p1: Int) -> String {
      return L10n.tr("Localizable", "my_listings.days_left", p1)
    }
    /// Mis Avisos
    internal static let title = L10n.tr("Localizable", "my_listings.title")
    internal enum AddButton {
      /// PUBLICAR
      internal static let text = L10n.tr("Localizable", "my_listings.add_button.text")
    }
    internal enum Area {
      /// %@ m²
      internal static func abbreviation(_ p1: Any) -> String {
        return L10n.tr("Localizable", "my_listings.area.abbreviation", String(describing: p1))
      }
    }
    internal enum Bathrooms {
      /// %d bñ
      internal static func abbreviation(_ p1: Int) -> String {
        return L10n.tr("Localizable", "my_listings.bathrooms.abbreviation", p1)
      }
    }
    internal enum Bedrooms {
      /// %d dor
      internal static func abbreviation(_ p1: Int) -> String {
        return L10n.tr("Localizable", "my_listings.bedrooms.abbreviation", p1)
      }
    }
    internal enum EmptyState {
      /// Aún no has agregado ningún aviso.
      internal static let title = L10n.tr("Localizable", "my_listings.empty_state.title")
      internal enum Button {
        /// Publicar un aviso
        internal static let text = L10n.tr("Localizable", "my_listings.empty_state.button.text")
      }
    }
    internal enum EmptyStateNotPublished {
      /// Todos tus avisos\n están publicados.
      internal static let title = L10n.tr("Localizable", "my_listings.empty_state_not_published.title")
    }
    internal enum EmptyStatePublished {
      /// Puedes publicar avisos desde el borrador\n o agregar uno nuevo
      internal static let subtitle = L10n.tr("Localizable", "my_listings.empty_state_published.subtitle")
      /// No tienes\n avisos publicados.
      internal static let title = L10n.tr("Localizable", "my_listings.empty_state_published.title")
    }
    internal enum ListingType {
      internal enum Rent {
        /// Alquiler
        internal static let title = L10n.tr("Localizable", "my_listings.listing_type.rent.title")
      }
      internal enum Sale {
        /// Venta
        internal static let title = L10n.tr("Localizable", "my_listings.listing_type.sale.title")
      }
    }
    internal enum Options {
      internal enum Delete {
        /// Eliminar
        internal static let title = L10n.tr("Localizable", "my_listings.options.delete.title")
      }
      internal enum Edit {
        /// Editar detalles
        internal static let title = L10n.tr("Localizable", "my_listings.options.edit.title")
      }
      internal enum Open {
        /// Abrir
        internal static let title = L10n.tr("Localizable", "my_listings.options.open.title")
      }
      internal enum Publish {
        /// Publicar
        internal static let title = L10n.tr("Localizable", "my_listings.options.publish.title")
      }
      internal enum Unpublish {
        /// Despublicar
        internal static let title = L10n.tr("Localizable", "my_listings.options.unpublish.title")
      }
        internal enum Share {
          /// Despublicar
          internal static let title = L10n.tr("Localizable", "my_listings.options.share.title")
        }
    }
    internal enum ParkingSlots {
      /// %d estac
      internal static func abbreviation(_ p1: Int) -> String {
        return L10n.tr("Localizable", "my_listings.parking_slots.abbreviation", p1)
      }
    }
    internal enum PropertyType {
      internal enum Apartments {
        /// Departamento
        internal static let title = L10n.tr("Localizable", "my_listings.property_type.apartments.title")
      }
      internal enum Commercial {
        /// Comercial
        internal static let title = L10n.tr("Localizable", "my_listings.property_type.commercial.title")
      }
      internal enum House {
        /// Casa
        internal static let title = L10n.tr("Localizable", "my_listings.property_type.house.title")
      }
      internal enum Land {
        /// Terreno
        internal static let title = L10n.tr("Localizable", "my_listings.property_type.land.title")
      }
      internal enum Office {
        /// Oficina
        internal static let title = L10n.tr("Localizable", "my_listings.property_type.office.title")
      }
    }
    internal enum Segment {
      /// No publicado
      internal static let notPublished = L10n.tr("Localizable", "my_listings.segment.not_published")
      /// Publicado
      internal static let published = L10n.tr("Localizable", "my_listings.segment.published")
    }
    internal enum Statistics {
      /// Interesados
      internal static let contacts = L10n.tr("Localizable", "my_listings.statistics.contacts")
      /// Favoritos
      internal static let favorites = L10n.tr("Localizable", "my_listings.statistics.favorites")
      /// Vistas
      internal static let views = L10n.tr("Localizable", "my_listings.statistics.views")
    }
    internal enum Status {
      internal enum Draft {
        /// Borrador
        internal static let title = L10n.tr("Localizable", "my_listings.status.draft.title")
      }
      internal enum Hidden {
        /// Borrador completo
        internal static let title = L10n.tr("Localizable", "my_listings.status.hidden.title")
      }
      internal enum Unpublished {
        /// Despublicado
        internal static let title = L10n.tr("Localizable", "my_listings.status.unpublished.title")
      }
      internal enum Visible {
        /// Publicado
        internal static let title = L10n.tr("Localizable", "my_listings.status.visible.title")
      }
    }
  }

  internal enum NotNow {
    internal enum Button {
      /// Ahora no
      internal static let title = L10n.tr("Localizable", "notNow.button.title")
    }
  }

  internal enum Payments {
    internal enum Alert {
      /// Aviso publicado con éxito
      internal static let listingPublishedSuccess = L10n.tr("Localizable", "payments.alert.listing_published_success")
    }
    internal enum Checkout {
      /// Nombre en la tarjeta
      internal static let cardName = L10n.tr("Localizable", "payments.checkout.card_name")
      /// cvc
      internal static let cvc = L10n.tr("Localizable", "payments.checkout.cvc")
      /// MM / AA
      internal static let experationDatePlaceholder = L10n.tr("Localizable", "payments.checkout.experation_date_placeholder")
      /// Pagar %@
      internal static func pay(_ p1: Any) -> String {
        return L10n.tr("Localizable", "payments.checkout.pay", String(describing: p1))
      }
      /// Al hacer clic en 'Pagar', estas aceptando nuestros Términos y Condiciones de Compra
      internal static let termsConditions = L10n.tr("Localizable", "payments.checkout.termsConditions")
      /// Comprar
      internal static let title = L10n.tr("Localizable", "payments.checkout.title")
    }
    internal enum Flow {
      /// Publica tu inmueble
      internal static let title = L10n.tr("Localizable", "payments.flow.title")
    }
    internal enum ListingPlan {
      /// Aviso Plus
      internal static let plus = L10n.tr("Localizable", "payments.listing_plan.plus")
      /// Aviso Premium
      internal static let premium = L10n.tr("Localizable", "payments.listing_plan.premium")
      /// Aviso Estándar
      internal static let standard = L10n.tr("Localizable", "payments.listing_plan.standard")
    }
    internal enum Period {
      /// %i días
      internal static func days(_ p1: Int) -> String {
        return L10n.tr("Localizable", "payments.period.days", p1)
      }
    }
    internal enum PeriodSelection {
      /// COMPRAR
      internal static let button = L10n.tr("Localizable", "payments.period_selection.button")
      /// Selecciona el período de publicación
      internal static let description = L10n.tr("Localizable", "payments.period_selection.description")
    }
    internal enum Plan {
      internal enum Expired {
        /// Expirado
        internal static let status = L10n.tr("Localizable", "payments.plan.expired.status")
      }
    }
    internal enum PlanSelection {
      /// SELECCIONAR PLAN
      internal static let button = L10n.tr("Localizable", "payments.plan_selection.button")
      /// Compara y selecciona la categoría de aviso que más te convenga.
      internal static let description = L10n.tr("Localizable", "payments.plan_selection.description")
    }
    internal enum PlanTitle {
      /// Plan Plus
      internal static let plus = L10n.tr("Localizable", "payments.plan_title.plus")
      /// Plan Premium
      internal static let premium = L10n.tr("Localizable", "payments.plan_title.premium")
      /// Plan Estándar
      internal static let standard = L10n.tr("Localizable", "payments.plan_title.standard")
    }
    internal enum Price {
      /// desde S/ %@
      internal static func from(_ p1: Any) -> String {
        return L10n.tr("Localizable", "payments.price.from", String(describing: p1))
      }
    }
    internal enum Profile {
      /// Constructor o Desarrollador
      internal static let company = L10n.tr("Localizable", "payments.profile.company")
      /// Para publicar como agente o constructora, por favor visite nuestra web babilonia.io
      internal static let description = L10n.tr("Localizable", "payments.profile.description")
      /// babilonia.io
      internal static let descriptionLink = L10n.tr("Localizable", "payments.profile.description_link")
      /// Dueño
      internal static let owner = L10n.tr("Localizable", "payments.profile.owner")
      /// Agente o Inmobiliaria
      internal static let realtor = L10n.tr("Localizable", "payments.profile.realtor")
    }
    internal enum ProfileSelection {
      /// SELECCIONAR PERFIL
      internal static let button = L10n.tr("Localizable", "payments.profile_selection.button")
      /// ¿Cómo deseas publicar?
      internal static let description = L10n.tr("Localizable", "payments.profile_selection.description")
    }
  }

  internal enum PhotoGallery {
    /// %i fotos
    internal static func photosCount(_ p1: Int) -> String {
      return L10n.tr("Localizable", "photo_gallery.photos_count", p1)
    }
    /// Galería de fotos
    internal static let title = L10n.tr("Localizable", "photo_gallery.title")
  }

  internal enum Popups {
    internal enum CameraAccess {
      /// Acceso a la cámara denegado. Por favor ingrese a Configuración -> Privacidad -> Cámara y active el acceso a Babilonia para utilizar esta función.
      internal static let text = L10n.tr("Localizable", "popups.camera_access.text")
    }
    internal enum DeleteDraftListing {
      /// ¿Está seguro que desea borrar esta información? La acción no se puede deshacer.
      internal static let text = L10n.tr("Localizable", "popups.delete_draft_listing.text")
      /// ¿Desea eliminar el borrador?
      internal static let title = L10n.tr("Localizable", "popups.delete_draft_listing.title")
    }
    internal enum ListingDeleted {
      /// Aviso eliminado con éxito
      internal static let text = L10n.tr("Localizable", "popups.listing_deleted.text")
    }
    internal enum PublishListing {
      /// ¿Está seguro de que desea publicar el aviso?
      internal static let text = L10n.tr("Localizable", "popups.publish_listing.text")
    }
    internal enum SignOut {
      /// No podrás buscar propiedades ni recibir notificaciones
      internal static let text = L10n.tr("Localizable", "popups.sign_out.text")
      /// ¿Desea cerrar sesión?
      internal static let title = L10n.tr("Localizable", "popups.sign_out.title")
      internal enum SignOut {
        /// Cerrar sesión
        internal static let title = L10n.tr("Localizable", "popups.sign_out.sign_out.title")
      }
    }
      internal enum DeleteAccount {
        /// No podrás buscar propiedades ni recibir notificaciones
        internal static let text = L10n.tr("Localizable", "popups.delete_account.text")
        /// ¿Desea cerrar sesión?
        internal static let title = L10n.tr("Localizable", "popups.delete_account.title")
        internal enum DeleteAccount {
          /// Cerrar sesión
          internal static let title = L10n.tr("Localizable", "popups.delete_account.delete_account.title")
        }
      }
    internal enum UnpublishListing {
      /// Podrá volver a publicarlo más tarde en cualquier momento
      internal static let text = L10n.tr("Localizable", "popups.unpublish_listing.text")
      /// ¿Desea despublicar el aviso?
      internal static let title = L10n.tr("Localizable", "popups.unpublish_listing.title")
    }
  }

  internal enum Profile {
    internal enum About {
      /// Sobre nosotros
      internal static let text = L10n.tr("Localizable", "profile.about.text")
      internal enum Privacy {
        /// Política de privacidad
        internal static let title = L10n.tr("Localizable", "profile.about.privacy.title")
      }
      internal enum Terms {
        /// Términos y condiciones
        internal static let title = L10n.tr("Localizable", "profile.about.terms.title")
      }
    }
    internal enum Account {
      /// Cuenta
      internal static let title = L10n.tr("Localizable", "profile.account.title")
      internal enum SignOut {
        /// Cerrar sesión
        internal static let title = L10n.tr("Localizable", "profile.account.sign_out.title")
      }
      internal enum DeleteAccount {
        /// Cerrar sesión
        internal static let title = L10n.tr("Localizable", "profile.account.delete_account.title")
      }
    }
    internal enum Currency {
      /// Moneda
      internal static let title = L10n.tr("Localizable", "profile.currency.title")
    }
    internal enum Email {
      /// Correo electrónico
      internal static let title = L10n.tr("Localizable", "profile.email.title")
    }
    internal enum Phone {
      /// Teléfono
      internal static let title = L10n.tr("Localizable", "profile.phone.title")
    }
  }

  internal enum Search {
    internal enum Bar {
      internal enum FiltersTip {
        /// Toque el filtro para eliminarlo
        internal static let text = L10n.tr("Localizable", "search.bar.filters_tip.text")
      }
      internal enum ListingsFound {
        /// Encontramos: %d Inmuebles
        internal static func text(_ p1: Int) -> String {
          return L10n.tr("Localizable", "search.bar.listings_found.text", p1)
        }
      }
    }
  }

  internal enum SearchByLocation {
    /// Ubicación actual
    internal static let currentLocation = L10n.tr("Localizable", "search_by_location.current_location")
    /// Ubicación no encontrada
    internal static let locationNotFound = L10n.tr("Localizable", "search_by_location.location_not_found")
    /// Búsquedas recientes
    internal static let recentSearches = L10n.tr("Localizable", "search_by_location.recent_searches")
    internal enum PermissionPopUp {
      /// Para permitir que Babilonia encuentre inmuebles cerca a usted, vaya a Configuración> Privacidad> Localización. Luego habilite la ubicación para la aplicación Babilonia.
      internal static let message = L10n.tr("Localizable", "search_by_location.permission_popUp.message")
      /// Active los servicios de ubicación
      internal static let title = L10n.tr("Localizable", "search_by_location.permission_popUp.title")
    }
  }

  internal enum Sign {
    internal enum Button {
      /// Ingresar
      internal static let title = L10n.tr("Localizable", "sign.button.title")
    }
  }

  internal enum SignUp {
    /// Crear cuenta
    internal static let title = L10n.tr("Localizable", "sign_up.title")
      
      internal enum FirstName {
        internal static let title = L10n.tr("Localizable", "sign_up.first_name.title")
      }
      internal enum LastName {
        internal static let title = L10n.tr("Localizable", "sign_up.last_name.title")
      }
      internal enum FullName {
        internal static let title = L10n.tr("Localizable", "sign_up.full_name.title")
      }
      internal enum Email {
        internal static let title = L10n.tr("Localizable", "sign_up.email.title")
      }
      internal enum Phone {
        internal static let title = L10n.tr("Localizable", "sign_up.phone.title")
      }
      internal enum Password {
        internal static let title = L10n.tr("Localizable", "sign_up.password.title")
      }
      internal enum CountryList {
        internal static let title = L10n.tr("Localizable", "sign_up.contry_list.title")
      }
  }

  internal enum Skip {
    internal enum Button {
      /// Saltar
      internal static let title = L10n.tr("Localizable", "skip.button.title")
    }
  }

  internal enum Start {
    internal enum Button {
      /// ¡COMENCEMOS!
      internal static let title = L10n.tr("Localizable", "start.button.title")
    }
      internal enum SignUpButton {
        /// ¡COMENCEMOS!
        internal static let title = L10n.tr("Localizable", "signup.button.title")
      }
      internal enum LogInButton {
        /// ¡COMENCEMOS!
        internal static let title = L10n.tr("Localizable", "login.button.title")
      }
  }

  internal enum TabBar {
    internal enum Favorites {
      /// Favoritos
      internal static let title = L10n.tr("Localizable", "tab_bar.favorites.title")
    }
    internal enum MyListings {
      /// Mis Avisos
      internal static let title = L10n.tr("Localizable", "tab_bar.my_listings.title")
    }
    internal enum Notifications {
      /// Inbox
      internal static let title = L10n.tr("Localizable", "tab_bar.notifications.title")
    }
    internal enum Profile {
      /// Perfil
      internal static let title = L10n.tr("Localizable", "tab_bar.profile.title")
    }
    internal enum Search {
      /// Buscar
      internal static let title = L10n.tr("Localizable", "tab_bar.search.title")
    }
  }

  internal enum Validation {
    internal enum Email {
      internal enum Error {
        ///  El formato de correo electrónico no es válido
        internal static let text = L10n.tr("Localizable", "validation.email.error.text")
      }
    }
    internal enum Empty {
      internal enum Error {
        /// El campo no debe estar vacío
        internal static let text = L10n.tr("Localizable", "validation.empty.error.text")
      }
    }
    internal enum LargeError {
      /// El campo no debe superar los %d caracteres 
      internal static func text(_ p1: Int) -> String {
        return L10n.tr("Localizable", "validation.large_error.text", p1)
      }
    }
    internal enum Numbers {
      internal enum NotANumberError {
        ///  Este campo debe estar en formato numérico
        internal static let text = L10n.tr("Localizable", "validation.numbers.not_a_number_error.text")
      }
      internal enum RangeError {
        /// Este valor debe estar en el rango de %d a %d
        internal static func text(_ p1: Int, _ p2: Int) -> String {
          return L10n.tr("Localizable", "validation.numbers.range_error.text", p1, p2)
        }
      }
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
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
