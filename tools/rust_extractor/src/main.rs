use anyhow::Result;
use clap::Parser;
use serde::{Deserialize, Serialize};
use std::fs;

#[derive(Parser, Debug)]
#[command(author, version, about, long_about = None)]
struct Args {
    /// Input file path
    #[arg(short, long)]
    input: String,

    /// Output file path
    #[arg(short, long)]
    output: String,
}

#[derive(Debug, Serialize, Deserialize)]
struct ExtractedData {
    source: String,
    timestamp: String,
    items: Vec<String>,
}

fn main() -> Result<()> {
    let args = Args::parse();

    println!("🦀 Rust Extractor");
    println!("   Input: {}", args.input);
    println!("   Output: {}", args.output);

    // Read input
    let content = fs::read_to_string(&args.input)?;

    // Process (placeholder - extract lines for now)
    let items: Vec<String> = content
        .lines()
        .filter(|line| !line.trim().is_empty())
        .map(|s| s.to_string())
        .collect();

    // Create output
    let data = ExtractedData {
        source: args.input.clone(),
        timestamp: chrono::Utc::now().to_rfc3339(),
        items,
    };

    // Write JSON output
    let json = serde_json::to_string_pretty(&data)?;
    fs::write(&args.output, json)?;

    println!("✅ Extracted {} items", data.items.len());

    Ok(())
}
