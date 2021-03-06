//
//  VirtualizationPrivate.swift
//  diavirt
//
//  Created by Kenneth Endfinger on 3/24/22.
//

#if DIAVIRT_USE_PRIVATE_APIS
import Foundation
import Virtualization

#if arch(arm64)
@objc protocol _VZAppleTouchScreenConfiguration {
    init()
}

@objc protocol _VZUSBTouchScreenConfiguration {
    init()
}

@objc protocol _VZMacKeyboardConfiguration {
    init()
}

@objc protocol _VZMacTrackpadConfiguration {
    init()
}
#endif

@objc protocol _VZUSBMassStorageDeviceConfiguration {
    init(attachment: VZStorageDeviceAttachment)
}

@objc protocol _VZEFIBootLoader {
    init()

    var efiURL: URL { get @objc(setEfiURL:) set }
    var variableStore: _VZEFIVariableStore { get @objc(setVariableStore:) set }
}

@objc protocol _VZEFIVariableStore {
    init(URL: URL) throws
}

@objc protocol _VZGDBDebugStubConfiguration {
    init(port: Int)
}

@objc protocol _VZVirtualMachineConfiguration {
    var _debugStub: _VZGDBDebugStubConfiguration { get @objc(_setDebugStub:) set }
}

@objc protocol _VZVNCAuthenticationSecurityConfiguration {
    init(password: String)
}

@objc protocol _VZVNCNoSecuritySecurityConfiguration {
    init()
}

@objc protocol _VZVNCServer {
    init(port: Int, queue: DispatchQueue, securityConfiguration: AnyObject)

    var virtualMachine: VZVirtualMachine { get @objc(setVirtualMachine:) set }
    var port: Int { get }

    func start()
    func stop()
}

@objc protocol _VZPL011SerialPortConfiguration {
    init()
}

@objc protocol _VZ16550SerialPortConfiguration {
    init()
}

#if arch(arm64)
@objc protocol _VZVirtualMachine {
    @objc(_startWithOptions:completionHandler:)
    func _start(with options: _VZVirtualMachineStartOptions) async throws

    @objc(_startWithOptions:completionHandler:)
    func _start(with options: _VZVirtualMachineStartOptions, completionHandler: @escaping (_ errorOrNil: Error?) -> Void)
}

@objc protocol _VZVirtualMachineStartOptions {
    init()

    var panicAction: Bool { get set }
    var stopInIBootStage1: Bool { get set }
    var stopInIBootStage2: Bool { get set }
    var bootMacOSRecovery: Bool { get set }
    var forceDFU: Bool { get set }
}

class VZExtendedVirtualMachineStartOptions {
    var panicAction: Bool?
    var stopInIBootStage1: Bool?
    var stopInIBootStage2: Bool?
    var bootMacOSRecovery: Bool?
    var forceDFU: Bool?

    func toActualOptions() -> _VZVirtualMachineStartOptions {
        let options = unsafeBitCast(NSClassFromString("_VZVirtualMachineStartOptions")!, to: _VZVirtualMachineStartOptions.Type.self).init()

        if let panicAction = panicAction {
            options.panicAction = panicAction
        }

        if let stopInIBootStage1 = stopInIBootStage1 {
            options.stopInIBootStage1 = stopInIBootStage1
        }

        if let stopInIBootStage2 = stopInIBootStage2 {
            options.stopInIBootStage2 = stopInIBootStage2
        }

        if let bootMacOSRecovery = bootMacOSRecovery {
            options.bootMacOSRecovery = bootMacOSRecovery
        }

        if let forceDFU = forceDFU {
            options.forceDFU = forceDFU
        }
        return options
    }
}
#endif

extension VZVirtualMachineConfiguration {
    func setGdbDebugStub(_ gdb: _VZGDBDebugStubConfiguration) {
        unsafeBitCast(self, to: _VZVirtualMachineConfiguration.self)._debugStub = gdb
    }
}

extension VZVirtualMachine {
    #if arch(arm64)
    func extendedStart(with options: VZExtendedVirtualMachineStartOptions, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        unsafeBitCast(self, to: _VZVirtualMachine.self)._start(with: options.toActualOptions()) { errorOrNil in
            if let error = errorOrNil {
                completionHandler(.failure(error))
            } else {
                completionHandler(.success(()))
            }
        }
    }

    func extendedStart(with options: VZExtendedVirtualMachineStartOptions) async throws {
        try await unsafeBitCast(self, to: _VZVirtualMachine.self)._start(with: options.toActualOptions())
    }
    #endif
}

enum VZPrivateUtilities {
    static func createVncServer(port: Int, queue: DispatchQueue, password: String? = nil) -> _VZVNCServer {
        unsafeBitCast(NSClassFromString("_VZVNCServer")!, to: _VZVNCServer.Type.self).init(port: port, queue: queue, securityConfiguration: password != nil ? createVncServerAuthentication(password: password!) : createVncServerNoSecurity())
    }

    static func createVncServerNoSecurity() -> _VZVNCNoSecuritySecurityConfiguration {
        unsafeBitCast(NSClassFromString("_VZVNCNoSecuritySecurityConfiguration")!, to: _VZVNCNoSecuritySecurityConfiguration.Type.self).init()
    }

    static func createVncServerAuthentication(password: String) -> _VZVNCAuthenticationSecurityConfiguration {
        unsafeBitCast(NSClassFromString("_VZVNCAuthenticationSecurityConfiguration")!, to: _VZVNCAuthenticationSecurityConfiguration.Type.self).init(password: password)
    }

    static func createEfiBootLoader(efiURL: URL, variableStoreURL: URL) throws -> VZBootLoader {
        let efiBootLoader = unsafeBitCast(NSClassFromString("_VZEFIBootLoader")!, to: _VZEFIBootLoader.Type.self).init()
        efiBootLoader.efiURL = efiURL
        let variableStore = try unsafeBitCast(NSClassFromString("_VZEFIVariableStore")!, to: _VZEFIVariableStore.Type.self).init(URL: variableStoreURL)
        efiBootLoader.variableStore = variableStore
        return unsafeBitCast(efiBootLoader, to: VZBootLoader.self)
    }

    static func createGdbDebugStub(_ port: Int) -> _VZGDBDebugStubConfiguration {
        unsafeBitCast(NSClassFromString("_VZGDBDebugStubConfiguration")!, to: _VZGDBDebugStubConfiguration.Type.self).init(port: port)
    }

    #if arch(arm64)
    static func createMacKeyboardConfiguration() -> VZKeyboardConfiguration {
        let macKeyboard = unsafeBitCast(NSClassFromString("_VZMacKeyboardConfiguration")!, to: _VZMacKeyboardConfiguration.Type.self).init()
        return unsafeBitCast(macKeyboard, to: VZKeyboardConfiguration.self)
    }

    static func createMacTrackpadConfiguration() -> VZPointingDeviceConfiguration {
        let macTrackpad = unsafeBitCast(NSClassFromString("_VZMacTrackpadConfiguration")!, to: _VZMacTrackpadConfiguration.Type.self).init()
        return unsafeBitCast(macTrackpad, to: VZPointingDeviceConfiguration.self)
    }

    static func createAppleTouchScreenConfiguration() -> _VZAppleTouchScreenConfiguration {
        unsafeBitCast(NSClassFromString("_VZAppleTouchScreenConfiguration")!, to: _VZAppleTouchScreenConfiguration.Type.self).init()
    }

    static func createUSBTouchScreenConfiguration() -> _VZUSBTouchScreenConfiguration {
        unsafeBitCast(NSClassFromString("_VZUSBTouchScreenConfiguration")!, to: _VZUSBTouchScreenConfiguration.Type.self).init()
    }
    #endif

    static func createPL011SerialPortConfiguration() -> VZSerialPortConfiguration {
        let serialPort = unsafeBitCast(NSClassFromString("_VZPL011SerialPortConfiguration")!, to: _VZPL011SerialPortConfiguration.Type.self).init()
        return unsafeBitCast(serialPort, to: VZSerialPortConfiguration.self)
    }

    static func create16550SerialPortConfiguration() -> VZSerialPortConfiguration {
        let serialPort = unsafeBitCast(NSClassFromString("_VZ16550SerialPortConfiguration")!, to: _VZ16550SerialPortConfiguration.Type.self).init()
        return unsafeBitCast(serialPort, to: VZSerialPortConfiguration.self)
    }
}
#endif
