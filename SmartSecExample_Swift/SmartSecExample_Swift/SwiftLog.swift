//
//  SwiftLog.swift
//  SmartSecExample_Swift
//
//  Created by Olga Dalton on 08/05/15.
//  Copyright (c) 2015 Olga Dalton. All rights reserved.
//

import Foundation

func releasePrint(object: Any) {
    Swift.print(object)
}

func releasePrintln(object: Any) {
    Swift.println(object)
}

func print(object: Any) {
    #if DEBUG
        Swift.print(object)
    #endif
}

func println(object: Any) {
    #if DEBUG
        Swift.println(object)
    #endif
}