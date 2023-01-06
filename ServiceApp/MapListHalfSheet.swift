//
//  MapList.swift
//  ServiceApp
//
//  Created by mimi on 12/25/21.
//

import SwiftUI

struct HalfSheetModalView: View {
    @EnvironmentObject var sheetObserver: SheetObserver
    @State private var currentPosition: CGSize = .zero
    @State private var newPosition: CGSize = .zero
    @State private var eventPresented: EventInformationModel = EventInformationModel()
    @State private var dragOffset: CGFloat = 0
    var body: some View {
        ZStack {
            MapListHalfSheet(sheetMode: $sheetObserver.sheetMode) {
                VStack(alignment: .leading) {
                    if self.sheetObserver.sheetMode == .full {
                        MapListElements(eventPresented: $eventPresented)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    if self.sheetObserver.sheetMode == .quarter {
                        HStack {
                            Text("Find Events")
                                .font(.system(size: 25))
                                .fontWeight(.bold)
                                .padding([.top], 10)
                            Spacer()
                            Button(action: {
                                self.sheetObserver.toFullSheet()
                                let hapticResponse = UIImpactFeedbackGenerator(style: .soft)
                                hapticResponse.impactOccurred()
                            }) {
                                Image(systemName: "magnifyingglass")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.blue)
                            }
                        }.padding()
                        .contentShape(Rectangle())
                        .gesture(TapGesture().onEnded { value in
                            if self.sheetObserver.sheetMode == .quarter {
                                self.sheetObserver.toFullSheet()
                            }
                        })
                        Spacer()
                    }
                    if self.sheetObserver.sheetMode == .half {
                        EventDetailView(data: self.sheetObserver.eventDetailData, sheetMode: self.$sheetObserver.sheetMode)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(CustomMaterialEffectBlur())
                .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                .offset(y: self.dragOffset)
                

            }
            .gesture(DragGesture()
                .onEnded { value in
                    self.currentPosition = CGSize(width: .zero, height: value.translation.height + self.newPosition.height)

                    if self.sheetObserver.sheetMode == .quarter && value.translation.height < -90 {
                        self.dragOffset = 0
                        self.sheetObserver.toFullSheet()
                    }
                    if self.sheetObserver.sheetMode == .full && value.translation.height > 100 {
                        self.dragOffset = 0
                        self.sheetObserver.toQuarterSheet()
                    }
                    if self.sheetObserver.sheetMode == .half && value.translation.height > 100 {
                        self.dragOffset = 0
                        self.sheetObserver.toQuarterSheet()
                    }

                }
            )
        }
    }
}

struct MapListHalfSheet<Content: View>: View {
    let content: () -> Content
    var sheetMode: Binding<SheetMode>
    
    init(sheetMode: Binding<SheetMode>, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.sheetMode = sheetMode
    }
    
    private func calculateOffset() -> CGFloat {
        switch sheetMode.wrappedValue {
        case .quarter:
            return UIScreen.main.bounds.height - 175
        case .half:
            return UIScreen.main.bounds.height / 3
        case .full:
            return 50
        }
    }
    var body: some View {
        content()
            .offset(y: calculateOffset())
            .animation(.spring())
            .edgesIgnoringSafeArea(.all)
    }
}

struct MapListHalfSheet_Previews: PreviewProvider {
    static var previews: some View {
        MapListHalfSheet(sheetMode: .constant(.quarter)) {
            
        }
    }
}
