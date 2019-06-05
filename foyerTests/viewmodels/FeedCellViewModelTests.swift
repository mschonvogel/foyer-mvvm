import XCTest
import RxSwift
import RxTest
@testable import foyer

class FeedCellViewModelTests: XCTestCase {
    private var disposeBag: DisposeBag!

    private let input_story = PublishSubject<Story>()
    private let input_prepareForReuse = PublishSubject<Void>()
    
    private let output_title = TestObserver<String?>()
    private let output_authorName = TestObserver<String?>()
    private let output_coverImage = TestObserver<UIImage?>()

    override func setUp() {
        Environment.reset()
        disposeBag = DisposeBag()

        let (title, authorName, coverImage) = feedCellViewModel(
            disposeBag: disposeBag,
            story: input_story,
            prepareForReuse: input_prepareForReuse
        )

        title
            .subscribe(output_title.observer)
            .disposed(by: disposeBag)
        authorName
            .subscribe(output_authorName.observer)
            .disposed(by: disposeBag)
        coverImage
            .subscribe(output_coverImage.observer)
            .disposed(by: disposeBag)
    }

    func test_success() {
        input_story.onNext(.mock)

        output_title.assertValues(["Test Story"])
        output_authorName.assertValues(["Malte"])
        output_coverImage.assertValues([.mock])
    }

    func test_prepareForReuse() {
        input_story.onNext(.mock)
        input_prepareForReuse.onNext(())

        output_title.assertValues(["Test Story", nil])
        output_authorName.assertValues(["Malte", nil])
        output_coverImage.assertValues([.mock, nil])
    }
}
