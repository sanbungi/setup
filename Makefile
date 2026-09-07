setup_tool: setup_ui.cpp
	g++ -Wall -Wextra -Wpedantic setup_ui.cpp -o setup_tool -lncursesw -ltinfo -static-libstdc++ -static-libgcc

test: setup_tool
	bash -n *.sh tests/*.sh
	bash tests/test_cli.sh ./setup_tool

clean:
	rm -f setup_tool
