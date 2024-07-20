use iced::widget::{button, column, text};
use log::info;

use crate::{Message, TabContent};

#[derive(Default)]
pub struct ProjectsTab {
    projects: Vec<String>
}

#[derive(Debug, Clone)]
pub enum ProjectsMessage {
    Open(String),
}

impl TabContent for ProjectsTab {
    fn title(&self) -> String {
        "Projects".to_string()
    }

    fn closable(&self) -> bool {
        false
    }

    fn update(&mut self, message: Message) {
        match message {
            Message::Projects(msg) => {
                match msg {
                    ProjectsMessage::Open(val) => { info!("{}", val); }
                }
            },
            _ => {}
        }
    }

    fn content(&self) -> iced::Element<'_, Message> {
        column![
            button("Test button").on_press(Message::Projects(ProjectsMessage::Open("test prj".to_string())))
        ].into()
    }
}
