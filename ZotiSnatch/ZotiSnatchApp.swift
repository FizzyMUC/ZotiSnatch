//
//  ZotiSnatchApp.swift
//  ZotiSnatch
//
//  Created by Pascal Marter on 21.02.25.
//

import SwiftUI
import AppKit
import Foundation

@main
struct ZotiSnatchApp: App {
    @StateObject private var viewModel = ZotiSnatchViewModel()
    
    var body: some Scene {
        MenuBarExtra("ZotiSnatch", systemImage: "music.note") {
            // The view will trigger an update when it appears.
            VStack(spacing: 10) {
                if viewModel.foundSpotifyLink {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Spotify link found!")
                    }
                    Button(action: {
                        viewModel.downloadSong()
                    }) {
                        Text("Download now!")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.horizontal)
                } else {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        Text("No Spotify link found!")
                    }
                    .padding(.horizontal)
                }
                
                
                // Text("Enter Spotify URL:")
                //    .font(.headline)
                
                // TextField("https://open.spotify.com/...", text: $viewModel.spotifyURL)
                //    .textFieldStyle(RoundedBorderTextFieldStyle())
                //    .padding(.horizontal)
                
                
            }
            .padding(10)
            .frame(width: 350, height: 180)
            .onAppear {
                viewModel.checkClipboardForSpotifyLink()
            }
            
            Divider()
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q", modifiers: [.command])
        }
    }
}

class ZotiSnatchViewModel: ObservableObject {
    @Published var spotifyURL: String = ""
    @Published var foundSpotifyLink: Bool = false
    
    /// Check the clipboard content for a valid Spotify URL.
    func checkClipboardForSpotifyLink() {
        // Access the general pasteboard
        let pasteboard = NSPasteboard.general
        
        // Check for a string value in the clipboard
        if let clipboardString = pasteboard.string(forType: .string),
           let url = URL(string: clipboardString),
           url.host?.contains("spotify.com") == true {
            // Update our state with the URL from clipboard
            DispatchQueue.main.async {
                self.spotifyURL = clipboardString
                self.foundSpotifyLink = true
            }
        } else {
            DispatchQueue.main.async {
                self.foundSpotifyLink = false
            }
        }
    }

    func downloadSong() {
        // let scriptPath = "/Users/\(NSUserName())/.local/pipx/venvs/zotify/bin/zotify"
        
        // Ensure the URL is properly quoted
        let quotedURL = "\"\(spotifyURL)\""

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["/Users/\(NSUserName())/.local/bin/zotify", quotedURL] // Full path as argument

        do {
            try process.run()
            process.waitUntilExit()
            print("Download started successfully!")
        } catch {
            print("Error running Zotify script: \(error)")
        }
    }

}
