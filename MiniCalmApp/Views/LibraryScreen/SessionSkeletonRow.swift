//
//  SessionSkeletonRow.swift
//  MiniCalmApp
//
//  Created by saeed shaikh on 21/09/26.
//

import SwiftUI

struct SessionSkeletonRow: View {

    var body: some View {
        HStack(spacing: 12) {

            RoundedRectangle(cornerRadius: 10)
                .fill(.gray.opacity(0.25))
                .frame(width: 70, height: 70)

            VStack(alignment: .leading, spacing: 8) {

                RoundedRectangle(cornerRadius: 5)
                    .fill(.gray.opacity(0.25))
                    .frame(width: 180, height: 16)

                RoundedRectangle(cornerRadius: 5)
                    .fill(.gray.opacity(0.25))
                    .frame(width: 110, height: 13)

                RoundedRectangle(cornerRadius: 5)
                    .fill(.gray.opacity(0.25))
                    .frame(width: 70, height: 11)
            }

            Spacer()
        }
        .padding(.vertical, 6)
        .redacted(reason: .placeholder)
    }
}

#Preview {
    SessionSkeletonRow()
}
