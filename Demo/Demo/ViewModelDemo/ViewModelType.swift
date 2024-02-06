//
//  ViewModelType.swift
//  Demo
//
//  Created by Коноплёв Андрей Андреевич on 06.02.2024.
//

public class ViewModelType<Input, Output> {
    typealias IO = InOut<Input, Output>

    let input: Input
    let output: Output

    init(input: Input, output: Output) {
        self.input = input
        self.output = output
    }

    convenience init(inOut: IO) {
        self.init(input: inOut.input, output: inOut.output)
    }

    func trackShow() {}
}

public struct InOut<Input, Output> {
    let input: Input
    let output: Output

    init(_ input: Input, _ output: Output) {
        self.input = input
        self.output = output
    }
}
