//
//  String+Add.swift
//  MyLocations
//
//  Created by Borzy on 02.09.18.
//  Copyright © 2018 Borzy. All rights reserved.
//

extension String {
    mutating func add(text: String?, separatedBy separator: String = "") {
       
        if let text = text {
            if !isEmpty {
                self += separator;
            }
            self += text;
        }
        
    }
}

