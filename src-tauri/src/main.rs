#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]


#[tauri::command]
fn add(a: i32, b: i32) -> i32 {
    a + b
}

fn main() {
    tauri::Builder::default()
        .invoke_handler(tauri::generate_handler![add])
        .run(tauri::generate_context!())
        .expect("erreur lors du démarrage de l'application Tauri");
}

#[cfg(test)]
mod tests {
    use super::add;

    #[test]
    fn test_add() {
        assert_eq!(add(2, 3), 5);
        assert_eq!(add(-1, 1), 0);
    }
}

