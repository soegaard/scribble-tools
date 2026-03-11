const Item = ({ title, ...props }) => (
  <>
    <UI.Card.Header title={title} {...props} />
    <UI.Card.Body>{title}</UI.Card.Body>
  </>
);
