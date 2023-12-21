##
## EPITECH PROJECT, 2023
## B-AIA-500-MPL-5-1-gomoku-nils.colire
## File description:
## Makefile
##

BIN = pbrain-gomoku-ai
SCRIPT = pbrain-gomoku-ai.rb

$(BIN):
	cp $(SCRIPT) $(BIN)
	chmod +x $(BIN)

all: $(BIN)

exe:
	pyinstaller --onefile $(SCRIPT)
	mv dist/$(BIN) $(BIN).exe

clean:
	rm -rf build dist __pycache__ $(BIN).spec

fclean: clean
	rm -rf $(BIN) $(BIN).exe

re: fclean all

.PHONY: all clean fclean re exe