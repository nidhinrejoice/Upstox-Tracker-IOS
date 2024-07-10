//
//  PortfolioReportView.swift
//  Upstox Tracker
//
//  Created by Nidhin Rejoice on 09/07/24.
//

import Foundation
import SwiftUI



struct ProfitLossReportView: View {
    @StateObject private var viewModel: ProfitLossViewModel
    @State private var selectedSortOption: LoginViewModel.SortOption = .name
    let financialYears = ["2024-25","2023-24", "2022-23", "2021-22", "2020-21"]
    @State private var selectedTab: Int = 0
    @State private var selectedFinancialYear: String = "2024-25"
    
    init(viewModel: ProfitLossViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading){
                if let error = viewModel.error {
                    Text("Error: \(error.localizedDescription)")
                }else if(viewModel.isLoading){
                    ProgressView("Fetching profit loss report...")
                }else{
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(financialYears, id: \.self) { year in
                                Button(action: {
                                    selectedFinancialYear = year
                                    viewModel.fetchProfitReport(financialYear: year)
                                }) {
                                    Text(year)
                                        .padding()
                                        .background(selectedFinancialYear == year ? Color.green : Color.gray)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    var totalPNL: Double {
                        viewModel.profitLossReport.reduce(0) { $0 + $1.totalProfit }
                    }
                    HStack{
                        Text("PNL :")
                            .font(.headline)
                        Text("\(formatCurrency(totalPNL))")
                            .font(.headline)
                            .foregroundColor(totalPNL >= 0 ? .deepGreen : .red)
                    }.padding()
                    Divider()  // Optional: Add a divider for visual separation
                    HStack{
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach([LoginViewModel.SortOption.name,LoginViewModel.SortOption.pnl,], id: \.self) { option in
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
                    List(viewModel.profitLossReport){ report in
                        VStack{
                            
                            HStack{
                                if(report.scriptName.isEmpty){
                                    Text("N/A : ")
                                }else{
                                    
                                    Text("\(report.scriptName.uppercased()) ")
                                        .font(.subheadline)
                                    Spacer()
                                    Text("\((formatCurrency(report.totalProfit)))")
                                        .font(.subheadline)
                                        .foregroundColor(report.totalProfit>0 ? Color.deepGreen : Color.red)
                                    
                                }
                            }.onTapGesture {
                                viewModel.showOrderHistory(scriptName: report.scriptName)
                            }
                        }
                    }.refreshable {
                        viewModel.fetchProfitReport(financialYear: selectedFinancialYear)
                    }
                }
            }
            .navigationTitle("Profit Report")
            .sheet(isPresented: $viewModel.orderHistoryShown) {
                VStack{
                    Text(viewModel.aggregateProfitLoss?.scriptName ?? "")
                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    
                    HStack{
                        Spacer()
                        let profit = viewModel.aggregateProfitLoss?.totalProfit ?? 0
                        Text(formatCurrency(profit))
                            .font(.headline)
                            .foregroundColor((profit) >= 0 ? .deepGreen : .red)
                            .padding()
                    }
                    List(viewModel.aggregateProfitLoss?.profitReport ?? []){ item in
                        VStack{
                            Text("\(item.buyDate) : \(formatCurrency(item.buyAverage)) X \(item.quantity) -> \(formatCurrency(item.buyAmount))")
                                .font(.caption2)
                            Text("\(item.sellDate) : \(formatCurrency(item.sellAverage)) X \(item.quantity) -> \(formatCurrency(item.sellAmount))")
                                .font(.caption2)
                            HStack{
                                Spacer()
                                Text(formatCurrency(item.sellAmount-item.buyAmount))
                                    .font(.headline)
                                    .foregroundColor((item.sellAmount-item.buyAmount) >= 0 ? .deepGreen : .red)
                            }
                            
                        }
                    }.padding()
                }
            }
        }.onAppear{
            viewModel.fetchProfitReport(financialYear: selectedFinancialYear)
        }
    }
}
