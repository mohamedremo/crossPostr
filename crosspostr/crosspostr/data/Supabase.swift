//
//  Supabase.swift
//  crosspostr
//
//  Created by Mohamed Remo on 22.01.25.
//
import Foundation
import Supabase

class Supabase: ObservableObject {
    let shared = SupabaseClient(
      supabaseURL: URL(string: "https://vyrwlpgqjcfzscgrcqrw.supabase.co")!,
      supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ5cndscGdxamNmenNjZ3JjcXJ3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzc0NTExOTAsImV4cCI6MjA1MzAyNzE5MH0.RNpf0dH6ox9zrwlZTrSJn6git4Il2Ro3JmlSJwpmxns"
    )
    
    private init(){}
    
}

