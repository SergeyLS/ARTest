//
//  float4x4.swift
//  ARTest
//
//  Created by Sergey Leskov on 6/20/18.
//  Copyright © 2018 Sergey Leskov. All rights reserved.
//

import Foundation
import ARKit

extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
}
}
