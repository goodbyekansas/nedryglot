fn main() {
    println!("{}", get_output_message("🦼"));
}

fn get_output_message(emoji: &str) -> String {
    format!("{} Brrrrrrrrrr!", emoji)
}

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn test_get_output_message() {
        let result = get_output_message("🐟");
        assert_eq!(result, "🐟 Brrrrrrrrrr!");
    }
}
