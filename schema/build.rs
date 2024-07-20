extern crate prost_build;

use std::io::Result;
use std::fs::read_dir;

fn main() -> Result<()> {
    let dir_content = read_dir("src/schema").unwrap();

    prost_build::compile_protos(&["src/schema/project.proto"], &["src/"]).unwrap();
    
    /*for x in dir_content.into_iter() {
        let path = x.unwrap().path().to_str().unwrap().to_string();
        println!("{}", path);
        prost_build::compile_protos(&[path], &["src/"]).unwrap();
    }*/

    Ok(())
}
