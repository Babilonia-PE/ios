enum HUDState {
    
    case initialized, presenting, hidden
    
}

protocol HUD {
    
    var state: HUDState { get }
    var stateDidChange: ((HUDState) -> Void)? { get set }
    
}
