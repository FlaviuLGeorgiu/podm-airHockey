//
//  MCUtility.swift
//  AirHockey
//
//  Created by Jonay Gilabert López on 08/04/2020.
//  Copyright © 2020 Miguel Angel Lozano Ortega. All rights reserved.
//

import Foundation
import MultipeerConnectivity

enum Scenes : Int {
    case MainMenu = 0
    case ListScene = 1
    case GameScene = 2
    case None = 3
}


protocol MultipeerConnectServiceDelegate {
    func connectedDevicesChanged(manager : MultipeerConnectService, connectedDevices: [String])
    func didReciveSize(didReceive text: String)
    func devicesNear(devices: [MCPeerID])
    func notConnected()
}

protocol GameControl {
    func puckService(didReceive text: String)
    func didGoal(_ goal: String)
    func didWin(_ win: String)
    func disconnect()
    func setPowerUp(didReceive text: String)
}

class MultipeerConnectService : NSObject {
    
    // El tipo de servicio debe ser una cadena única, con un máximo de 15 caracteres
    // y debe contener solo letras minúsculas, números y guiones.
    private let MultipeerConnectServiceType = "send-data"
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    private var myPeerId : MCPeerID
    private let serviceAdvertiser : MCNearbyServiceAdvertiser
    private let serviceBrowser : MCNearbyServiceBrowser
    
    var alert : UIAlertController?
    
    
    public var peerList = [MCPeerID]()
    
    var isBrowser : Bool = false
    
    var delegate : MultipeerConnectServiceDelegate?
    
    var gameDelegate : GameControl?
    
    lazy var session : MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        return session
    }()
    
    override init() {
        self.myPeerId = MCPeerID(displayName: self.appDelegate.myName!)
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
    
    func disconnect(){
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
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
        
        
        
        self.alert = AppAlert(title: "Se quiere conectar un usuario", message: peerID.displayName, preferredStyle: .alert)
        .addAction(title: "NO", style: .cancel) { _ in
            (self.appDelegate.gameScene as! ListScene).conectando = false
            invitationHandler(false, self.session)
        }
        .addAction(title: "SI", style: .default) { _ in
            self.isBrowser = false
            (self.appDelegate.gameScene as! ListScene).conectando = true
            (self.appDelegate.gameScene as! ListScene).addLoadingGif()
            invitationHandler(true, self.session)
        }
        .build()
        alert!.showAlert(animated: true)
        Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: false)
        
    }
    
    @objc func fireTimer() {
        self.alert!.dismiss(animated: true, completion: nil)
    }
    
    
    
    
}

extension MultipeerConnectService : MCNearbyServiceBrowserDelegate {
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        var existe = false
        for id in self.peerList{
            if peerID.displayName == id.displayName {
                existe = true
            }
        }
        if !existe {
            self.peerList.append(peerID)
            self.delegate?.devicesNear(devices: self.peerList)
        }
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
        
        switch state {
        case .connected:
             self.delegate?.connectedDevicesChanged(manager: self, connectedDevices:
                       session.connectedPeers.map{$0.displayName})
            break
        case .notConnected:
            if self.appDelegate.gameScene?.name == "ListScene"{
                print("Quitando GIF")
                self.delegate?.notConnected()
            }else{
                print("Cerrando partida")
                self.gameDelegate?.disconnect()
            }
            break
        default:
            break
        }
        
       
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
//        NSLog("%@", "didReceiveData: \(data)")
        let str = String(data: data, encoding: .utf8)!
        if str == "goal" {
            self.gameDelegate?.didGoal(str)
        }else if str == "win"{
            self.gameDelegate?.didWin(str)
        }else{
            let data = str.data(using: .utf8)!
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:CGFloat]
                {
                    if let _ = json["dx"]{
                        self.gameDelegate?.puckService(didReceive: str)
                    }else if let _ = json["height"]{
                        self.delegate?.didReciveSize(didReceive: str)
                    }else if let _ = json["powerup"]{
                        self.gameDelegate?.setPowerUp(didReceive: str)
                    }
                    
                } else {
                    print("bad json")
                }
            } catch let error as NSError {
                print(error)
            }
        }
        //self.delegate?.sendTextService(didReceive: str)
        
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

