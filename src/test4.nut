class SubscribeTest extends TestBase {

    urlSet = null;

	constructor() {
        urlSet ={};

		_create();

		imp.wakeup(1, _connect.bindenv(this));

		imp.wakeup(1, _unsubscribe.bindenv(this));
	}

	function _subscribe() {
		// test closed
		if (client == null) return;

		while (true) {
			try {
				// number of topics
				local not =	 ::irand(9) + 1;
				local topicSet = {};
				local topics = [];
				while(not--) {
					local url = _getUrl();
					print("Subscribing " + url);
					topics.append(url);
				}

				local id = client.subscribe(topics, "AT_MOST_ONCE", _onsubscribed.bindenv(this));

				if (id < 0) {
					print("Can't subscribe next group. Err=" + id )

					// imp.wakeup(20, _subscribe.bindenv(this)); // do not allow timer to overflow
				}

				print("Subscribe request " + id + " was sent");

				local next = ::irand(100);
				if (next > 50) break;

				print("Subscribe next at once");
			} catch (e) {
				print("Critical error at " + this + " Exception:" + e);
				break;
			}
		}
	}

	function _unsubscribe() {
		// test closed
		if (client == null) return;

		if (urlSet.len() > 0) {

			local not = ::irand(urlSet.len() - 1) + 1;

			local topics = [];
			foreach (key, value in urlSet) {
				not--;
				delete urlSet[key];
				print("Unsubscribing " + key);
				topics.append(key);
				if (not == 0) break;
			}

			client.unsubscribe(topics);

			print("Unsubscribe request was sent");
		}

		imp.wakeup(1, _unsubscribe.bindenv(this));
	}

	function _onsubscribed(result) {
		print("_onsubscribed");
		print(result);

		_subscribe();
	}

	function _onconnected(rc, info) {
		print("OnConnected " + rc + ":" + info);

		if (rc == 0) {
			_subscribe();
		} else {
			print("Critical error. Test aborted");
		}
	}

    function _getUrl() {
        local url = CLOUD2DEVICE_URL;
		local maxConst = 59049; // 3^10
		local rand = ::irand(maxConst);
		local div;
		local reminder = 0;
		while (true) {
			url = CLOUD2DEVICE_URL;
			div = rand;
			while (div > 0) {
				reminder = div % 3;
				div = div / 3;
				switch (reminder) {
					case 0:
						url = url + "/#"
						break;
					case 1:
						url = url + "/bu";
						break;
					case 2:
						url = url + "/ru";
						break;
				}
				
				if (reminder == 0) {
					break;
				}
				if (div < 3) {
					url = url + "/#"
					break;
				}
			}
			if (url in urlSet) {
				rand++;
				if (rand > maxConst) {
					rand = 1;
				}
			} else {
				urlSet[url] <- 1;
				break;
			}
		}
		return url;
    }

	function _typeof() {
		return "SubscribeTest";
	}
}