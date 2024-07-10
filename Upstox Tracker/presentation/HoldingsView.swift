//
//  HoldingsView.swift
//  Upstox Tracker
//
//  Created by Nidhin Rejoice on 09/07/24.
//

import Foundation
import SwiftUI


  func formatCurrency(_ value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "INR"
    formatter.maximumFractionDigits = 2
    return formatter.string(from: NSNumber(value: value)) ?? ""
}
struct HoldingsView : View {
    
    @StateObject private var viewModel: LoginViewModel
    @State private var selectedSortOption: LoginViewModel.SortOption 
    
    
    init(viewModel: LoginViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
        selectedSortOption = viewModel.sortBy
    }
    
    
    var body : some View{
        
        let urlString = "\(Constants.loginUrl)&client_id=\(Constants.clientId)&redirect_uri=\(Constants.redirectURI)"
        let url = URL(string: urlString)!
        NavigationView {
            VStack(alignment: .leading) {
                
                if viewModel.isLoggedIn {
                    if(viewModel.isLoading){
                        ProgressView("Fetching holdings...")
                    }else if(!viewModel.stocks.isEmpty){
                        var totalAmountInvested: Double {
                            viewModel.stocks.reduce(0) { $0 + $1.averagePrice * Double($1.quantity) }
                        }
                        var totalAmountCurrently: Double {
                            viewModel.stocks.reduce(0) { $0 + $1.lastPrice * Double($1.quantity) }
                        }
                        
                        var totalPNL: Double {
                            viewModel.stocks.reduce(0) { $0 + $1.pnl }
                        }
                        var dayPnl: Double {
                            viewModel.stocks.reduce(0) { $0 + $1.dayChange }
                        }
                        VStack(alignment: .leading){
                            Text("Invested \(formatCurrency(totalAmountInvested)) in \(viewModel.stocks.count) stocks")
                                .font(.headline)
                            
                            Text("Current Total is : \(formatCurrency(totalAmountCurrently))")
                                .font(.headline)
                            
                            HStack{
                                Text("PNL :")
                                    .font(.headline)
                                Text("\(formatCurrency(totalPNL))")
                                    .font(.headline)
                                    .foregroundColor(totalPNL >= 0 ? .deepGreen : .red)
                            }
                            HStack{
                                Text("Day PNL:")
                                    .font(.caption)
                                Text(formatCurrency(dayPnl))
                                    .font(.caption)
                                    .foregroundColor(dayPnl >= 0 ? .deepGreen : .red)
                            }
                        }.padding()
                        Divider()  // Optional: Add a divider for visual separation
                        HStack{
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(LoginViewModel.SortOption.allCases, id: \.self) { option in
                                        Button(action: {
                                            selectedSortOption = option
                                            viewModel.sortStocks(sortBy: option)
                                        }) {
                                            
                                            HStack {
                                                Text(option.rawValue)
                                                    .padding()
                                                    .background(viewModel.sortBy == option ? Color.accentColor : Color.gray)
                                                    .foregroundColor(.white)
                                                    .cornerRadius(8)
                                                if viewModel.sortAscending == true {
                                                    Image(systemName: "arrow.up")
                                                } else {
                                                    Image(systemName: "arrow.down")
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        ScrollViewReader{ proxy in
                            List(viewModel.stocks) { stock in
                                let investedAmt = stock.averagePrice * Double(stock.quantity)
                                HStack{
                                    VStack(alignment: .leading) {
                                        Text(stock.companyName)
                                            .font(.headline)
                                        HStack{
                                            Text("\(formatCurrency(stock.lastPrice))")
                                                .font(.subheadline)
                                            Text("\(String(format: "%.2f", (stock.dayChangePercentage))) % (\(formatCurrency(stock.dayChange)))")
                                                .font(.caption)
                                                .foregroundColor(stock.dayChangePercentage >= 0 ? .deepGreen: .red)
                                        }
                                        Text("Invested: \(formatCurrency(investedAmt)) (\(stock.quantity) X \(String(format: "%.2f", (stock.averagePrice))))")
                                            .font(.caption)
                                        Text("Current: \(formatCurrency(stock.lastPrice * Double(stock.quantity)))")
                                            .font(.caption)
                                        Text("PnL: \(formatCurrency(stock.pnl)) (\(String(format: "%.2f", (stock.pnlPercent)))%)")
                                            .font(.subheadline)
                                            .foregroundColor(stock.pnl >= 0 ? .deepGreen : .red)
                                    }
                                }
                            }
                            .onChange(of: selectedSortOption){_ in
                                withAnimation {
                                    if let firstStockId = viewModel.stocks.first?.id {
                                        proxy.scrollTo(firstStockId, anchor: .top)
                                    }
                                }
                            }
                            .navigationTitle("My Portfolio")
                            .refreshable {
                                viewModel.fetchUserHoldings()
                            }
                        }
                    } else if let error = viewModel.error {
                        Text("Error: \(error.localizedDescription)")
                    } else {
                        ProgressView()
                    }
                }
            }
            .navigationTitle("Upstox Tracker")
            .sheet(isPresented: $viewModel.isShowingWebView) {
                
                WebView(url: url) { authCode in
                    viewModel.handleAuthCode(authCode)
                }
                .edgesIgnoringSafeArea(.all)
//                .alert(isPresented: $viewModel.isLoggedIn) {
//                    Alert(title: Text("Success"), message: Text("You are logged in!"), dismissButton: .default(Text("OK")))
//                }
            }
        }
    }
}
