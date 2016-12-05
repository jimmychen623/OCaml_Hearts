open Card
open Player

module AI = struct
(* AI for Hearts Card Game *)

  type ai_id = string

  (* Contains all the hands of the four players and the list of cards that
   * have been played. There will be a 5 length list. Elements 1-4 will be the
   * player id and their associated hands. The AI will always be the first
   * element in the (id, card list) tuple. The last element will be a string
   * associated with the winner of a single round/next person to start. *)
  type simulated_state_v3 =  ((string * Card.card list) list * string)

  (* Contains all the hands of the four players and the list of cards that
   * have been played. There will be a 5 length list. Elements 1-4 will be the
   * player id and their associated hands. The AI will always be the first
   * element in the (id, card list) tuple. The second to last element will be a string
   * associated with the winner of a single round/next person to start. The last
   * element will be a boolean to keep track of whether or not hearts has been
   * broken. *)
  type final_state = {
    ai_id : string;
    mutable ai_cards : Card.card list;
    p1_id : string;
    mutable p1_cards : Card.card list;
    p2_id : string;
    mutable p2_cards : Card.card list;
    p3_id : string;
    mutable p3_cards : Card.card list;
    mutable total_cards_played : Card.card list;
    mutable current_cards_played : int option array;
    mutable next_player : string;
    mutable hearts_broken : bool;
  }
(* ========================================================================== *)
(* General AI Methods *)

  (* Retrieves card list for AI according to id *)
  let get_hand ai_id =
    failwith "Unimplemented"

(* Calculates the bounds for the suit of this card. The bounds are inclusive*)
let suit_bounds c : (int * int)=
  let (lowerbound:int) = (c-1)/13 in
  let (upperbound:int) = (c+12) / 13 in
  (lowerbound*13+1, upperbound*13)

(* Returns a hand without any hearts *)
let filter_hearts (card_lst: Card.card list) : Card.card list=
  List.filter (fun x -> x < 27 || x > 39) card_lst

(*Returns if c2 is of the same suit as c1*)
let is_same_suit (c1:Card.card) (c2:Card.card) =
  let lowerbound = fst (suit_bounds c1) in
  let upperbound = snd (suit_bounds c1) in
  (c2 >= lowerbound && c2 <= upperbound)



(* Returns the legal moves given a card, whether hearts have been broken, and a list of cards
 * If c is None, that means that it's the first card played that turn and the player can play
 * anything if hearts are broken, or any non-heart card if hearts are not broken.
 * If c is Some x, that means this is not the first card played that turn. If the current player
 * has a card that is of x's suit, he must play it. Otherwise, he can play anything if hearts
 * are broken, or any non-heart cart if hearts are not broken.
*)
let get_legal_moves (c:Card.card option)  (card_lst:Card.card list) (hearts_broken:bool ref) : Card.card list =
  match c with
  | None ->
    if !hearts_broken then card_lst
  else filter_hearts card_lst
  | Some x ->
    (let same_suit_as_c = Card.only_suit x card_lst in
    match same_suit_as_c with
    | [] -> card_lst
    | h::t -> same_suit_as_c)

(* Calculates the number of points a player receives from "winning" the hand*)
let rec score_of_turn (plays: (Player.player_id * Card.card) list) : int =
  match plays with
  | [] -> 0
  | h::t -> Card.point_of_card (snd h) + score_of_turn t

(* Compares two plays of the same suit and returns the (player,card) tuple that is the max*)
let max_play (play1: (Player.player_id * Card.card)) (play2: (Player.player_id * Card.card)) =
  if snd play1 > snd play2 then play1 else play2

(* Given a list of plays of the same suit, return the player that won the turn*)
let rec winner_of_turn (plays: (Player.player_id * Card.card) list) (curr_winner: (Player.player_id * Card.card)) : Player.player_id =
  match plays with
  | [] -> fst curr_winner
  | h::t -> winner_of_turn t (max_play h curr_winner)

  (* Plays desired card to the game. *)
  let play_card card hand =
    failwith "Unimplemented"

let rec choose_random_three lst acc =
  match lst with
  | h1::h2::h3::t -> h1::h2::h3::acc

(* Exchange method for the AI:
 * Follows a greedy approach to eliminate diamonds or clubs. Always keeps spades
 * of Jack or lower. Returns a list of three cards that the AI wishes to
 * exchange. *)
let ai_exchange (ai : Player.player) : (Player.player_id * Card.card list) =
  let ai_id = Player.get_id ai in
  let ai_hand = Player.get_cards ai in
  (ai_id, choose_random_three ai_hand [])

  (* Generates a random number from 0 to n given n. *)
  let randomizer (n:int) = Random.int n

(* ========================================================================== *)
(* Methods for Random Selection AI: *)

   (* Returns any available card that can be played. This AI does not care about
    * the score and just looks to play any card that is avaiable in its hand. *)
  let calc_card_to_play (c: Card.card option) (card_list : Card.card list) : Card.card =
    match c with
    | None   -> List.nth card_list (randomizer (List.length card_list))
    | Some x -> let moves = get_legal_moves c card_list (ref false) in
                List.nth moves (randomizer (List.length moves))

(* ========================================================================== *)
(* Methods for Greedy Selection AI: *)

  (* Finds the number of cards that a person has for a specific suit *)
  let cards_in_suit (card_list: Card.card list) =
    failwith "Unimplemented"

  (* Checks if current hand has any cards that are *)
  let need_same_suit (c : Card.card) (card_list : Card.card list) : bool =
    failwith "Unimplemented"

  (* For a given card list, the function returns the smallest card avaiable
   * in the list. The call to the helper function is hard-coded with a 53
   * because if the function is called, there is bound to be a card in the hand
   * and it guarantees a card is chosen. *)
  let smallest_card (card_list : Card.card list) =
    let rec smallest_card_helper acc (card_list : Card.card list) =
      match card_list with
      | []   -> acc
      | h::t -> if h < acc
                  then smallest_card_helper h t
                else smallest_card_helper acc t
    in
    smallest_card_helper 53 card_list

  (* Checks if current hand contains the Queen of Spades *)
  let rec has_queen_spades (card_list : Card.card list) : bool =
    match card_list with
    | []   -> false
    | h::t -> if h = 50
                then true
              else has_queen_spades t

  (* Checks if hand has hearts *)
  let has_hearts (card_list : Card.card list) : bool =
    failwith "Unimplemented"

  (* Returns card list with hearts only *)
  let heart_hand (card_list: Card.card list) : Card.card list =
    failwith "Unimplemented"

  (* Finds largest card *)
  let largest_card (card_list : Card.card list) =
    let rec largest_card_helper acc (card_list : Card.card list) =
      match card_list with
      | []   -> acc
      | h::t -> if h > acc
                  then largest_card_helper h t
                else largest_card_helper acc t
    in
    largest_card_helper 0 card_list

  (* Find next smallest card in given hand *)
  let next_smallest (c: Card.card) (card_list : Card.card list) =
    failwith "Unimplemented"
    (*
    let suit_list = List.filter (fun x -> x < c) in
    let sorted = List.sort compare suit_list in
    () *)


  (* Implements the card choice for score minimization portion of the greedy
   * algorithm. *)
  let score_minimizer (c: Card.card) (card_list : Card.card list) (cards_played : Card.card list) : Card.card =
    match cards_played with
    | []   -> smallest_card card_list
    | h::t -> (if(need_same_suit c card_list)
                then next_smallest c card_list
              else (if(has_queen_spades card_list)
                        then 50
                     else if (has_hearts card_list)
                        then let hand = heart_hand card_list
                             in
                             largest_card hand
                     else largest_card card_list))

  (* Greedy Algorithm AI:
   * The algorithm returns a card that minimizes the score for the player.
   * Specifically, it will play the lowest card avaiable if the suit has to be
   * the same. It will play the Queen of Spades when possible. *)
  let greedy_play (c: Card.card option) (card_list : Card.card list) (cards_played : Card.card list) : Card.card =
    match c with
    | None      -> smallest_card card_list
    | Some card -> let moves = get_legal_moves c card_list (ref false) in
                   score_minimizer card moves cards_played

(* ========================================================================== *)
(* Methods for Look-Ahead AI: *)

  (* Given the cards played, find the remaining cards in the game and assign
   * them to three other lists. *)
  let distribute_cards (total_cards_played : Card.card list) : simulated_state_v3 =
    failwith "Unimplemented"

  (* Removes a card from a single hand *)
  let remove_from_list (card: Card.card) (card_list: Card.card list) =
    List.filter (fun x -> x <> card) card_list

  (*Returns the player who "won" the hand and the number of points received*)
  let calculate_turn_result (plays: (Player.player_id * Card.card) list) : (Player.player_id * int) =
    let first_play = List.hd plays in
    let first_card = snd first_play in
    let score = score_of_turn plays in
    let considered_plays = List.filter (fun x -> is_same_suit first_card (snd x)) plays in
    let winner = winner_of_turn considered_plays first_play in
    (winner,score)

  (* Given a turn array, removes all the options for use in calculating the
   * play tuples. *)
  let no_option_array (turn_array : int option array) =
    match turn_array with
    |[|Some a; Some b; Some c; Some d|] -> [|a;b;c;d|]

  (* Given a player list and the turn array, the function produces a
   * player, card tuple that can then be used to calculate the score
   * and the winner of the current round. Order of player list is the
   * order in which they play. Position field is static. Turn array has
   * the same ordering. *)
  let convert_plays_to_tuple (turn_array : int array) (player_list : Player.player list) =
    let start_idx = -1 in
    let rec convert_helper (idx) (t_array) (p_list) (acc) =
      match p_list with
      | []   -> acc
      | h::t -> let index = idx + 1 in
                [(Player.get_id h, t_array.(index))] @ (convert_helper index t_array t acc)
    in convert_helper start_idx turn_array player_list []

  (* Given a list with option types, the function removes the option.
   * Precondition: List with Some x only.
   * Postcondition: List containing x and no option types. *)
  let eliminate_option lst : Card.card list =
    let rec eliminate_helper lst acc =
      match lst with
      | [] -> acc
      | (Some x)::t -> x :: eliminate_helper t acc
    in
    eliminate_helper lst []

  (* Converts current moves in the array to list form for the greedy approach.
   * If there is a None field, then the element is cut off from the list. *)
  let array_to_list (turn_array) : Card.card list =
    match turn_array with
    | [|a;b;c;d|] -> eliminate_option (List.filter (fun x -> x != None) [a;b;c;d])

  (* If the winner is the ai, return the number of points taken for the round.
   * Else return 0, meaning the AI does not take the trick. *)
  let winner_ai (turn_array : int option array) (ai_id : Player.player_id) (ordered_players : Player.player list): int =
    let result_tuples = convert_plays_to_tuple (no_option_array turn_array) ordered_players in
    let winner_tuple = calculate_turn_result result_tuples in
    if fst winner_tuple = ai_id
      then snd winner_tuple
    else 0

  (* Once the AI chooses the card, this method finishes the turn if the AI
   * is not the last player. This returns an updated state with all the cards
   * and hands of a simulation. Fills in the rest of the array *)
  let rec finish_turn (first_card : Card.card option) (turn_array: int option array) (ordered_players : Player.player list) =
    match turn_array with
    | [|a;b;c;d|] -> if b = None
                      then let player = List.nth ordered_players 1 in
                           let player_hand = player.cards in
                           let cards_played = array_to_list turn_array in
                           let card = greedy_play first_card player_hand cards_played in
                           let () = turn_array.(1) <- Some card
                         in finish_turn first_card turn_array ordered_players
                     else if c = None
                      then let player = List.nth ordered_players 2 in
                           let player_hand = player.cards in
                           let cards_played = array_to_list turn_array in
                           let card = greedy_play first_card player_hand cards_played in
                           let () = turn_array.(2) <- Some card
                         in finish_turn first_card turn_array ordered_players
                     else
                      let player = List.nth ordered_players 3 in
                      let player_hand = player.cards in
                      let cards_played = array_to_list turn_array in
                      let card = greedy_play first_card player_hand cards_played
                    in
                      turn_array.(3) <- Some card

  (* Looks at all valid cards for the current hand and completes one round (4
   * turns). Returns the number of points that the AI gains for one round. If
   * AI does not win, there there is no pts recieved. *)
  let advance_round (card: Card.card) (st : simulated_state_v3) (turn_array : int option array) (ordered_players : Player.player list) : int =
    match turn_array with
    | [|a;b;c;d|] ->
                      if a = None
                        then (let ai = List.nth ordered_players 0 in
                              let ai_id = ai.player_id in
                              let () = turn_array.(0) <- Some card in
                              let () = finish_turn (Some card) turn_array ordered_players in
                              winner_ai turn_array ai_id ordered_players)
                      else if b = None
                        then (let ai = List.nth ordered_players 1 in
                              let ai_id = ai.player_id in
                              let () = turn_array.(1) <- Some card in
                              let () = finish_turn (Some card) turn_array ordered_players in
                              winner_ai turn_array ai_id ordered_players)
                      else if c = None
                        then (let ai = List.nth ordered_players 2 in
                              let ai_id = ai.player_id in
                              let () = turn_array.(2) <- Some card in
                              let () = finish_turn (Some card) turn_array ordered_players in
                              winner_ai turn_array ai_id ordered_players)
                      else
                        let ai = List.nth ordered_players 3 in
                        let ai_id = ai.player_id in
                        let () = turn_array.(3) <- Some card in
                        winner_ai turn_array ai_id ordered_players

  (* Given that a game has started, this loop will simulate the entire game
   * for an intialized round and return the number of points that the AI
   * has amounted throughout the entire simulation *)
  let finish_game (st : simulated_state_v3) (total_cards_played) : int =
    let total_points = ref 0 in
    let id_card_tuples = fst st in
    match id_card_tuples with
    | ai::p1::p2::p3::l::[] -> let cards_played = snd l in
                                let () =
                               while (List.length total_cards_played != 52)
                                do
                                  ()
                                done
  in
  !total_points

  let create_state (turn_array : int option array) (ordered_players : Player.player list) (total_cards_played : Card.card list) =
    failwith "Unimplemented"
(*
  let find_first_idx lst =
    let find_first_idx_helper lst acc =
    match lst with
    | []   -> failwith "Not possible"
    | h::t -> if h = None
                then acc
              else find_first_idx_helper t (acc + 1)
    in find_first_idx_helper lst 0

  let original_array_to_list (turn_array : int option array) =
    match turn_array with
    | [|a;b;c;d|] -> [a;b;c;d] *)

  (* Finite Look-Ahead AI:
   * Calculates the best card by running a simulation of a round on every
   * card available for play in a single turn. Game_points represents the
   * number of rounds that the AI has won. *)
  let future_calc (st: simulated_state_v3) (turn_array : int option array) (ordered_players: Player.player list) (total_cards_played : Card.card list): Card.card =
    let legal_moves = List.hd (fst st) in
    let best_points = ref 0 in
    let best_card = ref 0 in
    let next_player = snd st in
    let rec future_calc_helper (legal_moves) (best_points) (best_card) =
        let game_points = ref 0 in
        match legal_moves with
        | []   -> !best_card
        | h::t -> let new_st = st in
                  let () = game_points := advance_round h new_st turn_array ordered_players in
                  let () = game_points := !game_points + finish_game new_st total_cards_played in
                  if !game_points < !best_points
                    then (best_points := !game_points;
                         best_card := h;
                         future_calc_helper t best_points best_card)
                  else future_calc_helper t best_points best_card
    in
    future_calc_helper (snd legal_moves) best_points best_card
  end
