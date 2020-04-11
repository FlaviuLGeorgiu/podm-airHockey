//
//  MCUtility.swift
//  AirHockey
//
//  Created by Jonay Gilabert López on 08/04/2020.
//  Copyright © 2020 Miguel Angel Lozano Ortega. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol MultipeerConnectServiceDelegate {
    func connectedDevicesChanged(manager : MultipeerConnectService, connectedDevices: [String])
    func sendTextService(didReceive text: String)
    func devicesNear(devices: [MCPeerID])
}

class MultipeerConnectService : NSObject {
    
    // El tipo de servicio debe ser una cadena única, con un máximo de 15 caracteres
    // y debe contener solo letras minúsculas, números y guiones.
    private let MultipeerConnectServiceType = "send-data"
    
    private let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    private let serviceAdvertiser : MCNearbyServiceAdvertiser
    private let serviceBrowser : MCNearbyServiceBrowser
    
    public var peerList = [MCPeerID]()
    
    var isBrowser : Bool = false
    
    var delegate : MultipeerConnectServiceDelegate?
    
    lazy var session : MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        return session
    }()
    
    override init() {
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: MultipeerConnectServiceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: MultipeerConnectServiceType)
        
        super.init()
        
        
        self.serviceAdvertiser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()
        
        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()
    }
    
    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }
    
    func getPeerList() -> [MCPeerID] {
        return self.peerList
    }
    
    func send(text : String) {
        NSLog("%@", "sendText: \(text) to \(session.connectedPeers.count) peers")
        
        if session.connectedPeers.count > 0 {
            do {
                try self.session.send(text.data(using: .utf8)!, toPeers: session.connectedPeers, with: .reliable)
            }
            catch let error {
                NSLog("%@", "Error for sending: \(error)")
            }
        }
        
    }
    
    // Método que se ejecutará para realizar una invitación a un peer encontrado. En este caso el peer ya estará preseleccionado.
    func invite(displayName: String) {
        self.isBrowser = true
        let conectingPeer = self.peerList.first(where: {$0.displayName == displayName})!
        serviceBrowser.invitePeer(conectingPeer, to: self.session, withContext: nil, timeout: 10)
        
    }
    
}

extension MultipeerConnectService : MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print ("didReceiveInvitationFromPeer \(peerID)")
        
        AppAlert(title: "Se quiere conectar un usuario", message: peerID.displayName, preferredStyle: .alert)
        .addAction(title: "NO", style: .cancel) { _ in
            // action
        }
        .addAction(title: "SI", style: .default) { _ in
             // action
            self.isBrowser = false
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            (appDelegate.gameScene as! ListScene).addLoadingGif()
            invitationHandler(true, self.session)
        }
        .build()
        .showAlert(animated: true)
   
    }
    
    
}

extension MultipeerConnectService : MCNearbyServiceBrowserDelegate {
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        //NSLog("%@", "foundPeer: \(peerID)")
       // NSLog("%@", "invitePeer: \(peerID)")
//        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
        self.peerList.append(peerID)
        self.delegate?.devicesNear(devices: self.peerList)
//        print("foundPeer: \(peerID)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "lostPeer: \(peerID)")
        // Eliminamos del array de peers encontrados la peer ID del objeto que ha perdido la conexión.
        self.peerList.removeAll { $0 == peerID }
        self.delegate?.devicesNear(devices: self.peerList)
    }
    
    
    
}

extension MultipeerConnectService : MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        NSLog("%@", "peer \(peerID) didChangeState: \(state.rawValue)")
        self.delegate?.connectedDevicesChanged(manager: self, connectedDevices:
            session.connectedPeers.map{$0.displayName})
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveData: \(data)")
        let str = String(data: data, encoding: .utf8)!
        self.delegate?.sendTextService(didReceive: str)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveStream")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        NSLog("%@", "didStartReceivingResourceWithName")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        NSLog("%@", "didFinishReceivingResourceWithName")
    }
    
}

