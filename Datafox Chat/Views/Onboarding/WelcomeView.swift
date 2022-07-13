//
//  WelcomeView.swift
//  Datafox Chat
//
//  Created by Juan Hernandez Pazos on 04/07/22.
//

import SwiftUI

struct WelcomeView: View {
    
    @Binding var currentStep: OnboardingStep
    
    var body: some View {
        VStack {
            Spacer()
            
            Image("onboarding-welcome")
            
            Text("Welcome to Test Chat")
                .font(Font.titleText)
                .padding(.top, 32)
            
            Text("Model app for Cyphertop chat functions and styles")
                .font(Font.bodyParagraph)
                .padding(.top, 8)
            
            Spacer()
            
            Button {
                // Next step
                currentStep = .phonenumber
            } label: {
                Text("Get Started")
            }
            .buttonStyle(OnboardingButtonStyle())
            
            Text("By tapping 'Get Started'...")
                .font(Font.smallText)
                .padding(.top, 14)
                .padding(.bottom, 60)
        }
        .padding(.horizontal)
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(currentStep: .constant(.welcome))
    }
}
