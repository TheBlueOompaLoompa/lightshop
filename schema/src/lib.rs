use prost::Message;

pub mod project {
    include!(concat!(env!("OUT_DIR"), "/lightshop.project.rs"));
}
