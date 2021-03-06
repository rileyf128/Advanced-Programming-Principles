	 (* Copyright (c) Gopalan Nadathur *)

(* Skeletion code for a solution to the graph coloring problem using exceptions *)

(* An exception for signalling a deadend in search *)
exception Search_Failure      

	    (* Some functions for displaying colorings *)

(* Printing a list using a function for printing items in the list *)
let printlist item_printer l =
   let rec printlist_aux l =
     match l with
     | [] -> Printf.printf "%c" ']'
     | (h::t) -> Printf.printf "%s" ", ";
                 item_printer h;
                 printlist_aux t
   in (Printf.printf "%c" '[';
       match l with
       | (h::t) -> item_printer h; printlist_aux t
       | _ -> printlist_aux l)

(* A function for displaying an integer item *)
let show_int i = Printf.printf "%d" i

(* A function for displaying a color (represented by a string) *)
let show_color c = Printf.printf "%s" c

(* A function for displaying a node, color pair *)
let show_node_and_color (n,c) =
   Printf.printf "("; show_int n; Printf.printf ","; show_color c; Printf.printf ")"

(* A function for showing a (complete) coloring *)
let show_coloring l =
   Printf.printf "\nColoring for the graph: "; printlist show_node_and_color l;
   Printf.printf "\n"

(* A function for interacting with the user; show the coloring and check
   if the user wants more colorings *)
let ask_user printer config =
   printer config;
   Printf.printf "More solutions (y/n)? ";
   if (read_line () = "y")
   then (raise Search_Failure)
   else ()


(* The part below represents the code that has to be written/completed to solve this
   problem. The main task is to fill out the definition of color_graph_aux that
   is currently a stub. NOTE THAT YOU MUST USE THE EXCEPTIONS APPROACH TO REALIZING
   SEARCH FOR CREDIT IN THIS PROBLEM.
   Some comments to help you in the task. The function color_graph_aux is intended
   to have the following type
         color_graph_aux : int list -> (int * string) list -> unit 
   The two arguments represent, respectively, the nodes still to be colored and
   the coloring already determined for the other nodes. The function should try
   to extend the already determined coloring (second argument) to cover the
   remaining nodes (first argument). It would do this by recursion on the first
   argument. The general scheme should be the following:
   
      1. Pick the first color from the list of colors for the first
         uncolored node that is compatible with the already determined
         coloring; the remaining colors will be alternatives to be
	 tried if this choice fails, to be signalled by an exception.
	 
      2. Try to color the remaining nodes in the extended colored
         environment using this process recursively. 
      3. If no nodes remain to be colored, interact with the user,
         to display the coloring and, if the user desires to find
	 another coloring; as you can see, the user's desire for
	 another coloring is signalled by an exception indicating
	 "failure" in the coloring. 
      4. If there are no possible choices left to color the first
         node, raise an exception.
    You may need auxiliary function definitions to realize this scheme.
    Include ALL such code BELOW so that we can see it easily when
    grading. Also note that some of the functions you might need may
    also be ones needed in the solution to Problem 1. If so, you may
    reuse those definitions here.
*)

(*Helper function to find valid element*)

let rec find n lst =
  match lst with
  | [] -> None
  | (h,x)::t -> if n = h then (Some x) else find n t

(*Helper function to choose a color*) 

let rec color_pick color = 
   match color with 
      |[] -> None
      |(h::t) -> Some(h,t)

(*Tests colors of neighbors*) 

let rec neighbor_colors color neighbor x =
  match neighbor with
  |[]-> true
  |(h::t) -> match (find h x) with
    |None -> neighbor_colors color t x
    |Some y -> if (color = y) then false else neighbor_colors color t x

(* helper function that ensures valid insertion *)
let rec color_valid n color x y =
  match (find n x) with
  |None -> true
  |Some n -> neighbor_colors color n y

(* The graph coloring function. The intended type is the following
   color_graph : int list -> (int * int list) list -> string list -> unit*)
let color_graph nodes adjacency colors = (*Colors = list of colors*)
   let rec color_graph_aux nodes colored = 
        let rec fill_nodes node1 node2 color =
             match (color_pick color) with
                |None -> raise Search_Failure
                |Some(x1,x2) -> if (color_valid node1 x1 adjacency colored)
	                              then try (color_graph_aux node2 ((node1,x1)::colored)) with
	                                 Search_Failure -> fill_nodes node1 node2 x2
	                           else fill_nodes node1 node2 x2
        in match nodes with
    |[] -> ask_user show_coloring colored
    |(h::t) -> fill_nodes h t colors
   in try (color_graph_aux nodes []) with
      Search_Failure -> Printf.printf "\nNo (more) colorings possible\n"

