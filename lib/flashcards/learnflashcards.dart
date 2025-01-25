import 'dart:math';

import 'package:flutter/material.dart';
import 'package:memorize_up/model/sets.dart';
import 'package:memorize_up/util/contentcontainer.dart';
import 'package:memorize_up/util/correctcounter.dart';
import 'package:memorize_up/util/wraptext.dart';
import 'package:memorize_up/util/colors.dart' as colors;


class LearnFlashcards extends StatefulWidget {

  final String name;
  final List<Flashcard> flashcards;

  const LearnFlashcards({super.key, required this.flashcards, required this.name});


  @override
  State<LearnFlashcards> createState() => _LearnFlashcardsState();

}

enum LearnMode {
  flashcards, multipleChoice, trueFalse, write
}

class _LearnFlashcardsState extends State<LearnFlashcards> {

  final _random = Random();
  var _index = -1;
  var _correctOption = -1;
  final List<int> _options = [];
  var _previousIndex = -1;
  var _waiting = false;
  var _optionSelected = -1;
  var _learnMode = LearnMode.multipleChoice;
  var _showTrue = false;
  var _truePicked = false;
  var _index2 = -1;
  late TextEditingController _textController;
  var _cardIndex = 0;
  var _showFront = true;
  final List<int> _indices = [];
  var _shuffled = false;
  var _onlyStarred = false;
  final _nCorrect = [];

  void nextFlashcard() {
    do {
      _index = _random.nextInt(widget.flashcards.length);
    } while ((_index == _previousIndex && _nCorrect.where((n) => n < 3).length > 1)
            || _nCorrect[_index] == 3);
    
    _previousIndex = _index;

    _showTrue = _random.nextBool();
    if (_showTrue) {
      _index2 = _index;
    } else {
      do {
        _index2 = _random.nextInt(widget.flashcards.length);
      } while (_index2 == _index);
    }

    _correctOption = _random.nextInt(4);
    _options.clear();
    for (var i = 0; i < 4; i++) {
      var indexToAdd = -1;
      if (i == _correctOption) {
        indexToAdd = _index;
      } else {
        do {
          indexToAdd = _random.nextInt(widget.flashcards.length);
        } while (_options.contains(indexToAdd) || indexToAdd == _index);
      }
      _options.add(indexToAdd);
    }
  }

  void next() {
    if (_onlyStarred) {
      do {
        nextFlashcard();
      } while (!widget.flashcards[_index].starred);
      return;
    }
    nextFlashcard();
  }

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();

    _indices.clear();
    _indices.addAll(List.generate(widget.flashcards.length, (index) => index));

    _nCorrect.clear();
    _nCorrect.addAll(List.generate(widget.flashcards.length, (index) => 0));

    setState(() {
      next();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  bool checkIfFinished() {
    if (_onlyStarred) {
      var nCorrectToCheck = [];
      for (var i = 0; i < widget.flashcards.length; i++) {
        if (widget.flashcards[i].starred) {
          nCorrectToCheck.add(_nCorrect[i]);
        }
      }
      return nCorrectToCheck.where((n) => n < 3).isEmpty;
    } else {
      return _nCorrect.where((n) => n < 3).isEmpty;
    }
  }
  @override
  Widget build(BuildContext context) {
    return PopScope(canPop: false, child: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(widget.name, style: Theme.of(context).textTheme.displayLarge!, overflow: TextOverflow.ellipsis),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 5.0),
            child: IconButton(
              onPressed: () {
                showDialog(context: context, builder: (context) => Dialog(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 10.0),
                        Center(child: Text('Options', style: Theme.of(context).textTheme.displayLarge!)),
                        const SizedBox(height: 20.0),
                        OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _learnMode = LearnMode.flashcards;
                            });
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.credit_card),
                          label: Text('Flashcards', style: Theme.of(context).textTheme.displayMedium!)
                        ),
                        const SizedBox(height: 10.0),
                        OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _learnMode = LearnMode.multipleChoice;
                            });
                            Navigator.pop(context);
                          }, 
                          icon: const Icon(Icons.list), 
                          label: Text('Multiple choice', style: Theme.of(context).textTheme.displayMedium!)
                        ),
                        const SizedBox(height: 10.0),
                        OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _learnMode = LearnMode.trueFalse;
                            });
                            Navigator.pop(context);
                          }, 
                          icon: const Icon(Icons.contrast), 
                          label: Text('True or false', style: Theme.of(context).textTheme.displayMedium!)
                        ),
                        const SizedBox(height: 10.0),
                        OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _learnMode = LearnMode.write;
                            });
                            Navigator.pop(context);
                          }, 
                          icon: const Icon(Icons.edit), 
                          label: Text('Write', style: Theme.of(context).textTheme.displayMedium!,)
                        ),
                        const SizedBox(height: 10.0),
                        OutlinedButton.icon(
                          onPressed: () {
                            if (widget.flashcards.where((flashcard) => flashcard.starred).length < 4) {
                              return;
                            }
                            setState(() {
                              _onlyStarred = !_onlyStarred;
                            });
                            Navigator.pop(context);
                          },
                          icon: Icon(!_onlyStarred ? Icons.star : Icons.star_outline),
                          label: Text(!_onlyStarred ? 'Only starred' : 'All flashcards', style: Theme.of(context).textTheme.displayMedium!)
                        ),
                        const SizedBox(height: 20.0)
                      ],
                    ),
                  ),
                ));
              },
              icon: const Icon(Icons.more_vert),
            )
          )
        ],
      ),
      body: ContentContainer(child: (() {
        if (_learnMode == LearnMode.flashcards) {
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            AspectRatio(
              aspectRatio: 1.5,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showFront = !_showFront;
                  });
                },
                
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(child: WrapText(
                      text: _showFront ? widget.flashcards[_indices[_cardIndex]].front : widget.flashcards[_indices[_cardIndex]].back, 
                      style: Theme.of(context).textTheme.displayMedium!
                    ))
                  ),
                )
              )
            ),
            const SizedBox(height: 10.0),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _cardIndex--;
                    if (_cardIndex < 0) {
                      _cardIndex = widget.flashcards.length - 1;
                    }
                    _showFront = true;
                  });
                },
                icon: const Icon(Icons.arrow_left)
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _showFront = !_showFront;
                  });
                },
                icon: const Icon(Icons.autorenew)
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _cardIndex++;
                    if (_cardIndex >= widget.flashcards.length) {
                      _cardIndex = 0;
                    }
                    _showFront = true;
                  });
                }, 
                icon: const Icon(Icons.arrow_right)
              )
            ]),
            const SizedBox(height: 20.0),
            Row(children: [Expanded(child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _shuffled = !_shuffled;
                  if (_shuffled) {
                    _indices.shuffle();
                  } else {
                    _indices.sort();
                  }
                });
              },
              icon: const Icon(Icons.shuffle),
              label: Text(_shuffled ? 'Unshuffle' : 'Shuffle', style: Theme.of(context).textTheme.displayMedium!)
            ))]),

          ]);
        }
        if (_learnMode == LearnMode.multipleChoice) {
          return Column(children: [
            WrapText(text: widget.flashcards[_index].front, style: Theme.of(context).textTheme.displayMedium!),
            const SizedBox(height: 20.0),
            CorrectCounter(n: _nCorrect[_index]),
            const SizedBox(height: 20.0),
            ...(() {
              var widgets = <Widget>[];
              for (var i = 0; i < 4; i++) {
                widgets.add(Row(children: [Expanded(child: ElevatedButton(
                  onPressed: () async {
                    if (_waiting || !mounted) {
                      return;
                    }
                    
                    setState(() {
                      _waiting = true;
                      _optionSelected = i;
                      if (_correctOption == i) {
                        _nCorrect[_index]++;
                      } else {
                        _nCorrect[_index] = 0;
                      }
                    });
                    
                    await Future.delayed(const Duration(seconds: 2));
                    if (!mounted) return;
                    _waiting = false;

                    if (checkIfFinished() && mounted) {
                      (() {
                        Navigator.pop(context);
                      })();
                      return;
                    }
                    if (!mounted) return;
                    setState(() {
                      next();
                    });
                  },
                  style: _waiting && _optionSelected == i ? ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(_correctOption == i ? colors.correctColor : colors.incorrectColor)
                  ) : (_waiting && _optionSelected != i && _correctOption == i ? const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(colors.correctColor)
                  ) : null),
                  child: _waiting && _optionSelected == i ? 
                  Icon(_correctOption == i ? Icons.check : Icons.close)
                  : Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: WrapText(text: widget.flashcards[_options[i]].back, style: Theme.of(context).textTheme.displayMedium!)
                  ),
                ))]));
                widgets.add(const SizedBox(height: 10.0));
              }
              return widgets;
            })()
          ]);
        }
        if (_learnMode == LearnMode.trueFalse) {
          return Column(children: [
            WrapText(text: widget.flashcards[_index].front, style: Theme.of(context).textTheme.displayMedium!),
            const SizedBox(height: 20.0),
            WrapText(text: widget.flashcards[_index2].back, style: Theme.of(context).textTheme.displayMedium!),
            const SizedBox(height: 20.0),
            CorrectCounter(n: _nCorrect[_index]),
            const SizedBox(height: 20.0),
            Row(children: [
              const SizedBox(width: 50.0),
              Expanded(child: ElevatedButton(
                onPressed: () async {
                  if (_waiting || !mounted) {
                    return;
                  }

                  setState(() {
                    _waiting = true;
                    _truePicked = true;
                    if (_showTrue) {
                      _nCorrect[_index]++;
                    } else {
                      _nCorrect[_index] = 0;
                    }
                  });
                  
                  await Future.delayed(const Duration(seconds: 2));
                  if (!mounted) return;

                  if (checkIfFinished() && mounted) {
                    (() {
                      Navigator.pop(context);
                    })();
                    return;
                  }
                  if (!mounted) return;
                  setState(() {
                    _waiting = false;
                    next();
                  });
                },
                style: _waiting && _truePicked ? ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(_showTrue ? colors.correctColor : colors.incorrectColor)
                ) : null,
                child: _waiting && _truePicked ? 
                Icon(_showTrue ? Icons.check : Icons.close)
                : Text('True', style: Theme.of(context).textTheme.displayMedium!),
              )),
              const SizedBox(width: 50.0),
              Expanded(child: ElevatedButton(
                onPressed: () async {
                  if (_waiting || !mounted) {
                    return;
                  }

                  setState(() {
                    _waiting = true;
                    _truePicked = false;
                    if (!_showTrue) {
                      _nCorrect[_index]++;
                    } else {
                      _nCorrect[_index] = 0;
                    }
                  });
                  
                  await Future.delayed(const Duration(seconds: 2));
                  if (!mounted) return;

                  if (checkIfFinished() && mounted) {
                    (() {
                      Navigator.pop(context);
                    })();
                    return;
                  }
                  if (!mounted) return;
                  setState(() {
                    _waiting = false;
                    
                    next();
                  });

                },
                style: _waiting && !_truePicked ? ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(!_showTrue ? colors.correctColor : colors.incorrectColor)
                ) : null,
                child: _waiting && !_truePicked ? 
                Icon(!_showTrue ? Icons.check : Icons.close)
                : Text('False', style: Theme.of(context).textTheme.displayMedium!),
              )),
              const SizedBox(width: 50.0)
            ])
          ]);
        }
        if (_learnMode == LearnMode.write) {
          return Column(children: [
            WrapText(text: widget.flashcards[_index].front, style: Theme.of(context).textTheme.displayMedium!),
            const SizedBox(height: 20.0),
            Row(children: [
              const SizedBox(width: 50.0),
              Expanded(child: TextField(
                controller: _textController,
                style: Theme.of(context).textTheme.displayMedium!,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'type your answer here',
                  hintStyle: Theme.of(context).textTheme.labelMedium!
                ),
                enabled: !_waiting,
              )),
              const SizedBox(width: 50.0),
            ]),
            const SizedBox(height: 20.0),
            CorrectCounter(n: _nCorrect[_index]),
            const SizedBox(height: 20.0),
            Row(children: [
              const SizedBox(width: 50.0),
              Expanded(child: ElevatedButton(
                onPressed: () async {
                  if (_waiting || !mounted) {
                    return;
                  }

                  setState(() {
                    _waiting = true;
                    if (_textController.text == widget.flashcards[_index].back) {
                      _nCorrect[_index]++;
                    } else {
                      _nCorrect[_index] = 0;
                    }
                  });

                  await Future.delayed(const Duration(seconds: 2));
                  if (!mounted) return;

                  if (checkIfFinished() && mounted) {
                    (() {
                      Navigator.pop(context);
                    })();
                    return;
                  }
                  if (!mounted) return;
                  setState(() {
                    _waiting = false;
                    _textController.text = '';
                    next();
                  });
                },
                style: _waiting ? ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(_textController.text == widget.flashcards[_index].back ? colors.correctColor : colors.incorrectColor)
                ) : null,
                child: _waiting ? Icon(
                  _textController.text == widget.flashcards[_index].back ? Icons.check : Icons.close
                ) : Text('Check', style: Theme.of(context).textTheme.displayMedium!),
              )),
              const SizedBox(width: 50.0)
            ]),
            const SizedBox(height: 10.0),
            Text(_waiting && _textController.text != widget.flashcards[_index].back ? 'Correct answer: ${widget.flashcards[_index].back}' : '',
            style: Theme.of(context).textTheme.displayMedium!)
          ]);
        }
        return const SizedBox();
      })()),
    ));
  }
}
