use log::{debug, error};
use iced::alignment::Vertical;
use iced::widget::{ button, column, row, scrollable, text, Row };
use iced::Alignment::Center;

use iced::{Element, Length, Renderer, Theme};

mod projects;
use projects::{ProjectsMessage, ProjectsTab};

fn main() -> iced::Result {
    env_logger::init();
    iced::program("Lightshop", Lightshop::update, Lightshop::view)
        .run_with(Lightshop::new)
}

#[derive(Default)]
struct Lightshop {
    tab: usize,
    tabs: Vec<Box<dyn TabContent>>
}

#[derive(Debug, Clone)]
enum Message {
    TabSelected(usize),
    TabClosed(usize),
    Projects(ProjectsMessage),
}

impl Lightshop {
    fn new() -> Self {
        Lightshop { tabs: vec![ Box::new(<ProjectsTab as std::default::Default>::default()) ], ..Default::default() }
    }

    fn update(&mut self, event: Message) {
        match event {
            Message::TabSelected(i) => {
                debug!("Selected {}", i);
                self.tab = i;
            },
            Message::TabClosed(i) => {
                self.tabs.remove(i);
                if self.tabs.len() <= i + 1 && self.tab > 0 {
                    self.tab = self.tabs.len() - 1;
                    self.tabs[self.tab].update(Message::TabSelected(self.tab));
                }
                debug!("Closed {}", i);
            }
            _ => {}
        }
        
        if self.tabs.len() > 0 { self.tabs[self.tab].update(event); }
    }

    fn view(&self) -> Element<Message> {
        let tab_buttons: Vec<Element<Message, Theme, Renderer>> =
            self.tabs.iter().enumerate().map(|(idx, tab)|
                button(
                    match tab.closable() {
                        true => row![
                            text(tab.title()).vertical_alignment(Vertical::Center),
                            button("x").on_press(Message::TabClosed(idx))
                        ],
                        false => row![
                            text(tab.title()).vertical_alignment(Vertical::Center),
                        ]
                    }.spacing(5).align_items(Center)
                ).on_press(Message::TabSelected(idx)).into()
            ).collect();
        let tab_row = Row::from_vec(tab_buttons).spacing(2);
        column![
            scrollable(tab_row),
            match self.tabs.get(self.tab) {
                Some(tab) => tab.content(),
                None => { error!("Out of tabs!"); text("No tabs! How?").into() }
            },
        ].width(Length::Fill).into()
    }
}

trait TabContent {
    fn title(&self) -> String;
    fn closable(&self) -> bool;
    fn update(&mut self, message: Message);
    fn content(&self) -> Element<'_, Message>;
}

