//
//  CannedMac.swift
//  diavirt
//
//  Created by Kenneth Endfinger on 3/22/22.
//

import Foundation

func createCannedMac() -> DAVirtualMachineConfiguration {
    DAVirtualMachineConfiguration(
        cpuCoreCount: 4,
        memorySizeInBytes: 6 * 1024 * 1024 * 1024,
        bootLoader: .init(
            linuxBootLoader: nil,
            macOSBootLoader: .init()
        ),
        platform: .init(
            genericPlatform: nil,
            macPlatform: .init(
                auxiliaryStoragePath: "macaux.bin",
                machineIdentifierPath: "macid.bin"
            )
        ),
        storageDevices: [
            .init(
                diskImageAttachment: .init(
                    imageFilePath: "root.img",
                    isReadOnly: false,
                    autoCreateSizeInBytes: UInt64(128 * 1024 * 1024 * 1024)
                ),
                virtioBlockDevice: .init()
            )
        ],
        serialPorts: [],
        entropyDevices: [],
        memoryBalloonDevices: [
            .init(
                virtioTraditionalMemoryBalloonDevice: .init()
            )
        ],
        networkDevices: [
            .init(
                virtioNetworkDevice: .init(macAddress: nil),
                natNetworkAttachment: .init()
            )
        ],
        graphicsDevices: [
            .init(
                macGraphicsDevice: .init(
                    displays: [
                        .init(
                            widthInPixels: 1920,
                            heightInPixels: 1080,
                            pixelsPerInch: 80
                        )
                    ]
                )
            )
        ],
        directorySharingDevices: [
            .init(
                virtioFileSystemDevice: .init(tag: "MacHome"),
                directoryShare: .init(
                    singleDirectoryShare: .init(
                        directory: .init(
                            path: FileManager.default.homeDirectoryForCurrentUser.path,
                            isReadOnly: true
                        )
                    ),
                    multipleDirectoryShare: nil
                )
            )
        ],
        socketDevices: [],
        keyboardDevices: [
            .init(
                usbKeyboardDevice: .init()
            )
        ],
        pointingDevices: [
            .init(
                usbScreenCoordinatePointingDevice: .init()
            )
        ],
        macRestoreImage: .init(
            latestSupportedRestoreImage: .init(),
            fileRestoreImage: nil
        )
    )
}