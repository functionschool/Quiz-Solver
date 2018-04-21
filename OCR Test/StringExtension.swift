//
//  StringExtension.swift
//  OCR Test
//
//  Created by Kousei Richeson on 4/20/18.
//  Copyright © 2018 Kousei Richeson. All rights reserved.
//

import Foundation

extension String {
    func contains(find: String) -> Bool{
        return self.range(of: find, options: .caseInsensitive) != nil
    }
}
