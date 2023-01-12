### 스크롤 구현 방식

스크롤을 구현하기 위해 UIstackView를 통해 UI들을 집어넣고

UIPanGesture를 통해 터치이벤트를 받아 스크롤을 구현 했습니다.

```jsx
for i in 1..<dataSource.count {
    guard let imageView = createImageView(index: i) else { continue }
    stackView.addArrangedSubview(imageView)
}
//init()
let gesture = UIPanGestureRecognizer(target: self, action: #selector(drag(with:)))
self.addGestureRecognizer(gesture)

//드래그 발생시
@objc func drag(with sender: UIPanGestureRecognizer) {
    let startPoint = self.bounds.origin.y
    let transition = sender.translation(in: self)
    self.bounds.origin.y = startPoint - transition.y
  
    sender.setTranslation(.zero, in: self)
}
```

스크롤을 아래로 내리면  transition.y 가 음수로 

위로 올리면 양수값이 나옵니다. 따라서 현재 위치에 transition을 적용해 현재위치를 갱신해줍니다.

위와같이 구현하고 dataSource에 미리 50개 혹은 그이상의 데이터를 넣고 한번에 모든 이미지를 스택뷰에 넣어주면 됩니다. 

그러나 화면에는 4~5개의 이미지만 보일것이니 메모리 낭비일수 있습니다.

UITableView 처럼 보이는 view만 할당하고 나머지는 재사용을 하기위해 dataSource에 6개의 값만 넣고

스크롤 발생시 이를 갱신하는 방식으로 구현하려 했습니다. 

## DataSource 구현

### 

image의 이름은 “image1” “image2” 이런식이므로 datasource에 Int값만 넣어줬습니다.

그래서 이렇게 이미지를 불러올수 있습니다.

```jsx
private func createImageView(index:Int) -> UIImageView? {
        guard let image = UIImage(named: "image\(index)") else {return nil}
        let imageView = UIImageView(image: image)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: cellHeight).isActive = true

        return imageView

    }
```

init에서 초기 1~6까지 넣어준상황에서 스크롤을 아래로 내려 1번 이미지가 가려질쯤에 datasource를 갱신해야 합니다.

### Datasource 갱신 타이밍

우선 스크롤이 아래로 내려가는지 위로 올라가는지 알아야 합니다. 

위에 구현했듯이 startPoint 보다 갱신된 bounds.y 가 높으면 아래로 내려감을 의미합니다.

```jsx
@objc func drag(with sender: UIPanGestureRecognizer) {
        let startPoint = self.bounds.origin.y
        let transition = sender.translation(in: self)
        self.bounds.origin.y = startPoint - transition.y
        
        if startPoint < self.bounds.origin.y {
            
            scrollDown(changeY: transition.y)

        } else {
            
            scrollUp(changeY: transition.y)

        }
        sender.setTranslation(.zero, in: self)
    }
```

위와같이 스크롤이 아래로 혹은 위로 갔는지 체크 가능합니다.

만약 스크롤이 아래로 내려갔다면 어느 특정한 시점에 datasource를 갱신해줘야합니다.

아래로 내려가는 이벤트는 자주 발생하지만 딱 한번만 갱신 시켜야 합니다.

그래서 changeOffset이라는 변수를 정의했습니다.

changeOffset는 스크롤이 변경된 만큼값이 갱신되고

은 한개의 이미지(앞으로 Cell이라 표현하겠음)의 높이만큼 값이 커진경우

dataSource를 갱신 시키고 다시 changeOffset 의 값을 Cell 높이만큼 빼줍니다.

만약 Cell의 높이가 100 이라면

changeOffset == 0  

→ 스크롤 발생 

→  changeOffset == 100 

→ 데이터 갱신

→changeOffset = changeOffset - 100 

```jsx
private func scrollDown(changeY: CGFloat) {
     
        changeOffset =  changeOffset - changeY
        if changeOffset > cellHeight {
                                //Todo: 데이터 갱신

                            //changeOffset 값 수정
                changeOffset -= cellHeight

            }
        }
    }
```

반대로 위로 올릴떄는 이렇게 됩니다.

```jsx
private func scrollUp(changeY: CGFloat) {
        changeOffset =  changeOffset - changeY
        if changeOffset < 0 {
               //Todo: 데이터 갱신

                            //changeOffset 값 수정
                changeOffset += cellHeight

            }
          
        }
    }
```

### 데이터 소스 갱신

이제 갱신할 타이밍을 찾았으니 갱신을 해줘야 합니다.

DataSource는 이런식으로 갱신되어야 합니다. 스크롤 아래로 내릴때

[1,2,3,4,5,6]  → [2,3,4,5,6,7]

첫번째 값을 빼고, 마지막값+1을 append해줍니다.

반대로 스크롤을 위로 올릴때

[2,3,4,5,6,7] →  [1,2,3,4,5,6]

마지막 값을 빼고 ,첫번째값-1 을 insert해줍니다.

```jsx
private func scrollDown(changeY: CGFloat) {
     
        changeOffset =  changeOffset - changeY
        if changeOffset > cellHeight {
            var temp = dataSource
            if let last = dataSource.last {
                temp.remove(at: 0)
                temp.append(last + 1)
                changeOffset -= cellHeight

            }
                        //데이터 갱신
            dataSource = temp
                        //bounds.y 변경
            self.bounds.origin.y -= cellHeight
            reloadData()
        }
    }

private func reloadData() {
        stackView.subviews.forEach { $0.removeFromSuperview() }
        for i in 0..<dataSource.count {
            if let imageView = createImageView(index: dataSource[i]) {
                stackView.addArrangedSubview(imageView)
            }

        }
    }
```

위 처럼 self.bounds.origin.y -= cellHeight

bounds를 변경하지 않으면 스크롤의 위치가 이상해집니다.

stackview에서 가장 맨위 view가 빠져버렸기 때문에 

bounds 또한 갱신해줘야 합니다.

```jsx
//Scroll UP
private func scrollUp(changeY: CGFloat) {
    changeOffset =  changeOffset - changeY
    if changeOffset < 0 {
        var temp = dataSource
        if let first = dataSource.first {
           
            temp.removeLast()
            temp.insert(first - 1, at: 0)
            changeOffset += cellHeight

        }
        dataSource = temp
        self.bounds.origin.y += cellHeight
        reloadData()
        
    }
}
```

### 스크롤 정지하기

만약 가장 아래나 가장 위 까지 스크롤이 되었다면 멈춰야합니다.

scrollDownEnded , scrollUpEnded 라는 bool 타입을 정의했습니다.

```jsx
let startPoint = self.bounds.origin.y
        let transition = sender.translation(in: self)
        self.bounds.origin.y = startPoint - transition.y
        
        if startPoint < self.bounds.origin.y {
            if scrollDownEnded {
                self.bounds.origin.y = cellHeight
                return
            }
            scrollUpEnded = false
            scrollDown(changeY: transition.y)

        } else {
            if scrollUpEnded {
                self.bounds.origin.y = 0
            }
            scrollDownEnded = false
            scrollUp(changeY: transition.y)

        }
        sender.setTranslation(.zero, in: self)
    }
```

위와 같이 scrollEnd일시 bounds.y를 다시 바꿔줍니다. 

그리고 아래로 내릴시 scrollUpEnded 는 다시 false 로 수정해줍니다.

이제 scroll End 시점을 찾아야합니다. 해당 시점은 datasource가 갱신되는 시점에

index 범위를 넘어가는순간이 정확합니다.

정해놓은 마지막 index가 1~50 사이라면

index 0을 추가하려 할때 혹은 51을 추가하려 할때 그전에 Scroll End해버리고 리턴합니다.

```jsx
private func scrollDown(changeY: CGFloat) {
     
        changeOffset =  changeOffset - changeY
        if changeOffset > cellHeight {
            var temp = dataSource
            if let last = dataSource.last {
                if last > lastImageIndex-1 {
                    scrollDownEnded = true
                    return }
                temp.remove(at: 0)
                temp.append(last + 1)
                changeOffset -= cellHeight

            }

            dataSource = temp
            self.bounds.origin.y -= cellHeight
            reloadData()
        }
    }

private func scrollUp(changeY: CGFloat) {
        changeOffset =  changeOffset - changeY
        if changeOffset < 0 {
            var temp = dataSource
            if let first = dataSource.first {
                                    // 스크롤 종료
                if first < 2 {
                    scrollUpEnded = true
                    return }
                temp.removeLast()
                temp.insert(first - 1, at: 0)
                changeOffset += cellHeight

            }
            dataSource = temp
            self.bounds.origin.y += cellHeight
            reloadData()
            
        }
    }
```

### 성능 비교

기존

```jsx
Physical footprint (peak):  42.2M
                     VIRTUAL RESIDENT    DIRTY  SWAPPED VOLATILE   NONVOL    EMPTY   REGION 
REGION TYPE           SIZE     SIZE     SIZE     SIZE     SIZE     SIZE     SIZE    COUNT (non-coalesced) 
===========          ======= ========    =====  ======= ========   ======    =====  ======= 

TOTAL                   2.3G   843.7M   484.3M       0K       0K   463.0M       0K     1518 
```

현재

```jsx
Physical footprint (peak):  21.8M

                     VIRTUAL RESIDENT    DIRTY  SWAPPED VOLATILE   NONVOL    EMPTY   REGION 
REGION TYPE           SIZE     SIZE     SIZE     SIZE     SIZE     SIZE     SIZE    COUNT (non-coalesced) 
===========          ======= ========    =====  ======= ========   ======    =====  ======= 

TOTAL                  1.8G   252.9M    61.7M       0K       0K    43.1M       0K     1466 
```
