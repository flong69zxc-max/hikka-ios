import SwiftUI

struct ContentView: View {
    @StateObject private var pythonRunner = PythonRunner()
    @State private var isRunning = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Заголовок
                VStack {
                    Image(systemName: "terminal.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    Text("Hikka Wrapper")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("iOS Python Userbot")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.top, 30)
                
                // Кнопка запуска
                Button(action: {
                    if !isRunning {
                        isRunning = true
                        pythonRunner.startHikka()
                    }
                }) {
                    HStack {
                        Image(systemName: isRunning ? "circle.fill" : "play.circle.fill")
                        Text(isRunning ? "Running..." : "Start Hikka")
                    }
                    .font(.title2)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isRunning ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(isRunning)
                .padding(.horizontal)
                
                // Консоль логов
                VStack(alignment: .leading) {
                    HStack {
                        Text("Console Log")
                            .font(.headline)
                        Spacer()
                        Button(action: {
                            pythonRunner.consoleOutput = ""
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.horizontal)
                    
                    ScrollViewReader { proxy in
                        ScrollView {
                            Text(pythonRunner.consoleOutput)
                                .font(.system(.body, design: .monospaced))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .id("bottom")
                        }
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(8)
                        .onChange(of: pythonRunner.consoleOutput) { _ in
                            withAnimation {
                                proxy.scrollTo("bottom", anchor: .bottom)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .frame(maxHeight: .infinity)
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
