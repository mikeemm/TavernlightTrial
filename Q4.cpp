void Game::addItemToPlayer(const std::string& recipient, uint16_t itemId)
{
	Player* player = g_game.getPlayerByName(recipient);
	if (!player) {
		// Initializing a pointer with the 'new' keyword allocates memory for it on the heap,
		// which will be lost yet remain allocated if the early return below is reached.
		player = new Player(nullptr);
		if (!IOLoginData::loadPlayerByName(player, recipient)) {
			// So we will free this memory before doing so and prevent a memory leak.
			delete player;
			return;
		}
	}

	// This method is also presumably allocating new memory in the heap.
	Item* item = Item::CreateItem(itemId);
	if (!item) {
		// In this case however, this early return is only being called if the pointer
		// failed to be created, so there is no memory leak here.
		return;
	}

	if (g_game.internalAddItem(player->getInbox(), item, INDEX_WHEREEVER, FLAG_NOLIMIT) != RETURNVALUE_NOERROR) {  // RETURNVALUE_NOERROR is taken from the TFS source code.
		// We do however need to delete 'item' when we have failed to store it within 'player', as it will
		// become inaccessible otherwise, creating a leak.
		delete item;
	}

	// 'g_game.getPlayerByName' returns a player pointer that it already contains within.
	// 'IOLoginData::loadPlayerByName' fills a new, empty pointer with data from the database.
	// We can assume then that when loading up 'player' in the second manner, it is because the
	// player is not actually online, and that is why their data must be fetched from the database.
	if (player->isOffline()) {
		IOLoginData::savePlayer(player);
		// Using this info, we can delete 'player' safely in here before the function ends,
		// knowing that we will not be deleting live data contained within 'g_game' since 'player' has not
		// come from nor has been saved into its player pointer array.
		delete player;
		// We must remember to delete 'item' too even if it got saved into the player, since deleting the player does
		// not mean the pointers contained within it will also be deleted.
		delete item;
		// And now, there should be no more leaks.
	}
}