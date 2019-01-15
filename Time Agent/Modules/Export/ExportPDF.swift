//
//  ExportPDF.swift
//  Time Agent
//
//  Created by Viktor Hundahl Strate on 15/01/2019.
//  Copyright © 2019 Viktor Hundahl Strate. All rights reserved.
//

import Cocoa
import WebKit

struct ExportPDF {
    
    private static func saveWebViewAsPDF (webView: WebView, path: URL) {
        print("Saving web view as pdf")
        
        let printAttrs: [NSPrintInfo.AttributeKey : Any] = [
            NSPrintInfo.AttributeKey.jobDisposition: NSPrintInfo.JobDisposition.save,
            NSPrintInfo.AttributeKey.jobSavingURL: path as NSURL
        ]
        
        let printInfo: NSPrintInfo = NSPrintInfo(dictionary: printAttrs)
        printInfo.paperSize = NSMakeSize(595, 842)
        printInfo.topMargin = 0
        printInfo.leftMargin = 0
        printInfo.rightMargin = 0
        printInfo.bottomMargin = 0
        
        let printOp: NSPrintOperation = NSPrintOperation(view: webView.mainFrame.frameView.documentView, printInfo: printInfo)
        printOp.showsPrintPanel = false
        printOp.showsProgressPanel = false
        printOp.run()
        
        print("Saved PDF")
    }
    
    static func exportAsync(project: Project, path: URL) {
        
        DispatchQueue.main.async {
            print("PDF Export starting...")
            let html = ExportHTML.toHtml(project: project)
            
            let webView = WebView()
            webView.mainFrame.loadHTMLString(html, baseURL: nil)
            
            var waitUntilLoaded: (() -> Void)!
            
            waitUntilLoaded = {
                print("Waiting for webview to load")
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                    if webView.isLoading {
                        waitUntilLoaded()
                    } else {
                        saveWebViewAsPDF(webView: webView, path: path)
                    }
                }
            }
            
            waitUntilLoaded()

        }

        print("PDF Export call finished")
    }
}
