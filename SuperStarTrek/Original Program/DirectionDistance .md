#  <#Title#>

            Button(action: {coordinateAlert = true
              computerAlert = false
            })
            {
              CommandText(text: "Direction & Distance Calculator")
                .alert("Direction & Distance Calculator", isPresented: $coordinateAlert, actions: {
                  TextField("Quadrant X Coordinate  (x,y):", text: $quadrantX)
                    .keyboardType(.decimalPad)
                    .onSubmit {
                    }
                  TextField("Quadrant Y Coordinate  (x,y):", text: $quadrantY)
                    .keyboardType(.decimalPad)
                    .onSubmit {
                    }
                  TextField("Sector X Coordinate  (x,y):", text: $sectorX)
                    .keyboardType(.decimalPad)
                    .onSubmit {
                    }
                  TextField("Sector Y Coordinate  (x,y):", text: $sectorY)
                    .keyboardType(.decimalPad)
                    .onSubmit {
                    }
                  Button("Calculate", action: {
                    game.getDistanceAndDirection(W1: Int(quadrantX) ?? 0, X: Int(quadrantY) ?? 0, C1: Int(sectorX) ?? 0, A: Int(sectorY) ?? 0)
                  })
                  Button("Cancel", role: .cancel, action: {})
                }, message: {
                  Text("Calculate Distance & Direction")
                })
            }
