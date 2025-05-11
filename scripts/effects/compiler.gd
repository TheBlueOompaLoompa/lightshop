class_name Compiler

func compile(graph: GraphEdit):
    var connections = graph.get_connection_list()
    for connection in connections:
        print(connection)
